@REF:rails
§SCOPE{Rails_8.1(Ruby_3.4/4.0_patched)|Rails_7.2_legacy,fullstack/API/hybrid,PRs∈{app/,config/},action>~10L,model>~200L,AR∈controllers/views}

§PAT{dir_contract
  app/{models/,controllers/,views/,components/(ViewComponent),services/,forms/,queries/,jobs/(SolidQueue|Sidekiq|GoodJob),mailers/,helpers/(tinyPres),policies/(Pundit,opt),channels/(ActionCable)};
  ¬app/lib/,¬app/utils/,¬app/managers/; generic⇒lib/
}

§PAT{arch
  skinnyControllers:req→delegate→render; >1_resp⇒service; strong_params⇒`params.expect(invoice: [:due_date, line_items: [[:sku, :amount]]])`(Rails_8+,safer_than_`require.permit`); HTTP_422⇒`:unprocessable_content`(¬deprecated `:unprocessable_entity`);
  auth:Rails_8+ built-in `bin/rails generate authentication`(Session/Current/passwords;¬Devise_for_simple_auth);
  services:{nsDomain(`Invoices::Create`,`Invoices::MarkPaid`),¬suffix(`InvoiceCreator`),¬`Invoices::Manager`; `self.call`→`new.call`; return_`Data.define(:success?, :invoice, :errors)`(immutable_Result,¬bool/bareRecord); multiWrite∈`ApplicationRecord.transaction`; catch `ActiveRecord::RecordInvalid`; catch/log_notify_`StandardError`_postCommit};
  forms:{multiModel∨nonColFields∨condVal⇒FormObj(`ActiveModel::Model`+`ActiveModel::Attributes`); `form_with model:@form`};
  queries:{reused∨scope>3_chainedConds∨takesParams⇒QueryObj(accepts `scope:`)};
  jobs:{Rails8_modest⇒SolidQueue; highThroughput/Redis/obs⇒Sidekiq; pass_IDs_¬records; idempotent_`perform`(atLeastOnce); explicit `retry_on`/`discard_on`};
  viewComponent:{condRender∨>2_args∨reused>3_places⇒`ViewComponent::Base`(isolatedTests)>partials};
  hotwire_vs_SPA:{default⇒Hotwire(TurboFrames=partial,TurboStreams=serverPush,Stimulus=smallJS); React/Vue⇔SPA};
  rails8_stack:{DB-backed(SolidQueue,SolidCache,SolidCable)⇒0_Redis_vs_DB_load(modest); Redis_wins_highScale; Propshaft(assets)+Thruster(HTTP/2_proxy)+Kamal_2(DockerDeploy)}
}

§PAT{ar_callbacks_concerns
  N+1:`includes`(auto),`preload`(sepQueries),`eager_load`(JOIN_filterAssoc),`strict_loading`(raises);
  counter_cache:`belongs_to :post, counter_cache: true`+`add_column :posts, :comments_count, :integer, default: 0, null: false`(existingRows_need_backfill);
  callbacks:OK_pureNorm(`normalizes :email, with: ->(e) { e.strip.downcase }`[Rails_7.1+]>manual_`before_validation`); ¬sideFx(`after_create`/`after_save`⇒service);
  concerns(`ActiveSupport::Concern`):ONLY_if_reusable≥2_unrelatedModels(`SoftDeletable`); ¬singleModel(`InvoiceCalculations`⇒`Invoice`)
}

§ANTI{
  godControllers(>~80L); fatModels(30+_methods/>~200L); callbackChains(`after_save :a,:b,:c`);
  `accepts_nested_attributes_for`_complex/crossModel; `default_scope`_critical(hidesRecords⇒namedScope);
  DB_conceptModels(`UserRole`,`OrderStatus`,`InvoiceState`⇒enums); JS_fw_before_Hotwire;
  deprecated_`:unprocessable_entity`(use_`:unprocessable_content`); unpatched_Ruby_micro_versions(apply_security_patches)
}

§PAT{code
```ruby
class InvoicesController < ApplicationController
  def create
    r = Invoices::Create.call(params: invoice_params, user: Current.user)
    r.success? ? redirect_to(r.invoice, notice: "Invoice created") : (@invoice = r.invoice; render(:new, status: :unprocessable_content))
  end
  private
  def invoice_params = params.expect(invoice: [:customer_id, :due_date, line_items: [[:description, :amount]]])
end
module Invoices
  class Create
    Result = Data.define(:success?, :invoice, :errors)
    def self.call(params:, user:) = new(params:, user:).call
    def initialize(params:, user:) = (@params, @user = params, user)
    def call
      inv = build_invoice; ApplicationRecord.transaction { inv.save! }
      begin; InvoiceMailer.created(inv).deliver_later; AccountingExportJob.perform_later(inv.id)
      rescue StandardError => e; Rails.logger.error("Notify failed #{inv.id}: #{e.message}") end
      Result.new(success?: true, invoice: inv, errors: nil)
    rescue ActiveRecord::RecordInvalid => e; Result.new(success?: false, invoice: e.record, errors: e.record.errors)
    end
    private
    def build_invoice
      inv = @user.invoices.new(@params.except(:line_items)); inv.line_items.build(@params[:line_items])
      inv.tax_total = TaxCalculator.call(inv); inv.total = inv.line_items.sum(&:amount) + inv.tax_total; inv
    end
  end
end
class SignupForm
  include ActiveModel::Model; include ActiveModel::Attributes
  attribute :email, :string; attribute :password, :string; attribute :company_name, :string; attribute :terms_accepted, :boolean
  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP
  validates :password, presence: true, length: { minimum: 12 }
  validates :company_name, presence: true; validates :terms_accepted, acceptance: true
  attr_reader :user, :company
  def save
    return false unless valid?
    ApplicationRecord.transaction { @company = Company.create!(name: company_name); @user = @company.users.create!(email:, password:, role: :owner) }; true
  rescue ActiveRecord::RecordInvalid => e; errors.merge!(e.record.errors); false
  end
end
module Invoices
  class Overdue
    def self.call(scope: Invoice.all, as_of: Time.current) = new(scope:, as_of:).call
    def initialize(scope:, as_of:) = (@scope, @as_of = scope, as_of)
    def call = @scope.where(status: :sent, due_date: ..@as_of).where.not(id: Payment.where(created_at: ..@as_of).pluck(:invoice_id)).includes(:customer, :line_items)
  end
end
# Idempotent Job + add_index :accounting_exports, :idempotency_key, unique: true
class AccountingExportJob < ApplicationJob
  queue_as :exports; retry_on AccountingApi::TransientError, wait: :polynomially_longer, attempts: 5; discard_on AccountingApi::PermanentError
  def perform(invoice_id)
    inv = Invoice.find(invoice_id)
    exp = AccountingExport.create_or_find_by!(invoice: inv, idempotency_key: "invoice-export-#{inv.id}-#{inv.updated_at.to_i}")
    return if exp.completed_at?
    rec = AccountingApi.export(inv, idempotency_key: exp.idempotency_key)
    exp.update!(completed_at: Time.current, external_id: rec.id)
  end
end
class InvoiceStatusBadgeComponent < ViewComponent::Base
  STATUS_CLASSES = { draft: "bg-gray-100 text-gray-800", sent: "bg-blue-100 text-blue-800", paid: "bg-green-100 text-green-800", overdue: "bg-red-100 text-red-800" }.freeze
  def initialize(invoice:) = (@invoice = invoice)
  def call = tag.span(@invoice.status.humanize, class: "rounded-full px-2 py-1 text-sm #{STATUS_CLASSES.fetch(@invoice.status.to_sym, 'bg-gray-100')}")
end
class User < ApplicationRecord; normalizes :email, with: ->(e) { e.strip.downcase }; end
module SoftDeletable
  extend ActiveSupport::Concern
  included { scope :active, -> { where(deleted_at: nil) }; scope :deleted, -> { where.not(deleted_at: nil) } }
  def soft_delete! = update!(deleted_at: Time.current); def restore! = update!(deleted_at: nil)
end
```
}

§REL{../SKILL.md:svcBoundaries+adapterPatterns,error-handling.md:typedErrors+retries+userMsgs}
