@REF:laravel-testing
§USE{Laravel_12_13;Pest_5(PHP_8.4+,PHPUnit_13,TIA,Playwright_browser_tests)|PHPUnit;pre-PR,post-refactor,post-dep-upgrade,pre-deploy,new_feature,Sanctum|Passport_API,Eloquent(models,rels,scopes,accessors),HTTP_controllers,FormRequests,fakes(HTTP,Mail,Notification,Queue,Storage,Event)}
§TDD{1:RED(Product::factory()->create()⇒assertDatabaseHas)→2:GREEN(migration,model,factory)→3:REFACTOR(keep_green)}

§CFG{phpunit.xml
  `bootstrap="vendor/autoload.php" colors="true" schema="vendor/phpunit/phpunit/phpunit.xsd"`;
  suites:`Unit`(`tests/Unit`,suffix=`Test.php`),`Feature`(`tests/Feature`,suffix=`Test.php`);
  `<php><env>`:`APP_ENV=testing`,`BCRYPT_ROUNDS=4`,`CACHE_STORE=array`,`DB_CONNECTION=sqlite`,`DB_DATABASE=:memory:`,`MAIL_MAILER=array`,`QUEUE_CONNECTION=sync`,`SESSION_DRIVER=array`
}

§PAT{BaseTestCase:`Tests\TestCase extends Illuminate\Foundation\Testing\TestCase`
  `setUp()`:`parent::setUp()`; call `$this->withoutExceptionHandling()` ONLY for non-HTTP exception tests (suppresses `assertStatus()`);
  helpers:`actingAsUser()`→`User::factory()->create()`+`$this->actingAs($u)`; `actingAsAdmin()`→`User::factory()->admin()->create()`+`$this->actingAs($a)`
}

§PAT{Factories(`database/factories/`, `extends Factory`)
  `UserFactory`(`protected static ?string $password=null`): `definition()`→`['name'=>fake()->name(),'email'=>fake()->unique()->safeEmail(),'email_verified_at'=>now(),'password'=>static::$password ??= Hash::make('password'),'remember_token'=>Str::random(10),'role'=>'user']`; states:`admin()`→`['role'=>'admin']`, `unverified()`→`['email_verified_at'=>null]`;
  `ProductFactory`: `definition()`→`['name'=>fake()->unique()->words(3,true),'slug'=>fn(array $a)=>Str::slug($a['name']),'description'=>fake()->paragraph(),'price'=>fake()->numberBetween(100,100000),'stock'=>fake()->numberBetween(0,100),'is_active'=>true,'user_id'=>UserFactory::new()]`; state:`outOfStock()`→`['stock'=>0]`;
  usage:`::factory()->create(attrs?)`|`->admin()->create()`|`->count(n)->create()`|`->make()`(unpersisted)|`->has(Product::factory()->count(3))->create()`|`->count(3)->sequence(['role'=>'admin'],['role'=>'editor'],['role'=>'user'])->create()`
}

§PAT{Unit_HTTP_API(`use RefreshDatabase`)
  Models(`Tests\Unit\Models`): `$this->assertArrayNotHasKey('password',$u->toArray())`; `$this->assertCount(1,User::admin()->get())`; `$this->assertCount(3,Product::active()->get())`; `$this->assertTrue($product->user->is($user))`;
  HTTP(`Tests\Feature\Http\Controllers`): `$this->get(route('products.create'))->assertRedirect(route('login'))`; `$this->actingAs($u)->post(route('products.store'),$data)->assertRedirect(route('products.index'))`+`$this->assertDatabaseHas('products',['name'=>'New Product','user_id'=>$u->id])`; `$this->post(route('products.store'),[])->assertSessionHasErrors(['name','price'])`; `$this->actingAs($attacker)->delete(route('products.destroy',$product))->assertForbidden()`;
  JSON_API(`Tests\Feature\Http\Controllers\Api`): `$this->getJson('/api/products')->assertUnauthorized()`; `$this->actingAs($u)->getJson('/api/products')->assertOk()->assertJsonCount(5,'data')->assertJsonStructure(['data'=>[['id','name','price']],'meta'=>['current_page','last_page','total']])`; `$this->actingAs($u)->postJson('/api/products',$data)->assertCreated()->assertJsonPath('data.name','API Product')`; `$this->actingAs($attacker)->deleteJson("/api/products/{$product->id}")->assertForbidden()`;
  Sanctum: register `postJson('/api/register',['name','email','password','password_confirmation'])->assertCreated()->assertJsonStructure(['data'=>['user','token']])`; login `postJson('/api/login',['email','password'])->assertOk()->assertJsonStructure(['data'=>['token']])`; bad_creds `postJson('/api/login',...)->assertUnprocessable()`; bearer `$t=$u->createToken('test')->plainTextToken; $this->withToken($t)->getJson('/api/user')->assertOk()->assertJsonPath('data.email',$u->email)`
}

§PAT{Fakes_Authz_Pest
  `Http::fake(['api.stripe.com/*'=>Http::response(['id'=>'pi_123','status'=>'succeeded'],200)])`; err:`Http::response(['error'=>'card_declined'],402)`+`$this->expectException(PaymentFailedException::class)`; retry:`Http::sequence()->pushStatus(408)->pushStatus(200)`;
  `Mail::fake(); Mail::assertSent(OrderConfirmation::class, fn($m)=>$m->hasTo($order->user->email))`;
  `Notification::fake(); Notification::assertSentTo($user, WelcomeUser::class)`;
  `Queue::fake(); Queue::assertPushed(ProcessImage::class, fn($j)=>$j->product->id===$product->id)`;
  `Storage::fake('public'); $f=UploadedFile::fake()->image('photo.jpg',200,200); post('/avatar',['avatar'=>$f])->assertSessionHasNoErrors(); Storage::disk('public')->assertExists('avatars/'.$f->hashName())`;
  `Event::fake(); Event::assertDispatched(OrderShipped::class, fn($e)=>$e->order->id===$order->id)`;
  Artisan:`$this->artisan('newsletter:send')->expectsOutput('...')->assertExitCode(0); Mail::assertSent(NewsletterMail::class,5)`;
  Authz:`Gate::before` super-admin `$this->actingAs($super)->delete(route('posts.destroy',$post))->assertRedirect(); $this->assertSoftDeleted($post)`;
  Pest_5:`pest()->extend(Tests\TestCase::class)->use(RefreshDatabase::class)->in('Feature'); it('...',fn()=>$this->get(route('products.index'))->assertOk()->assertViewHas('products'));`;
  Pest_4_5_extras:Playwright_browser_tests(`visit('/login')->fill('email',...)->click('Sign in')->assertSee('Dashboard')`),TIA_Test_Impact_Analysis(run_only_impacted_tests_locally),architecture_tests(`arch()->preset()->laravel()`)
}

§CMD{Coverage
  PHPUnit:`vendor/bin/phpunit --coverage-html coverage --coverage-clover clover.xml` (clover for CI thresholds);
  Pest:`vendor/bin/pest --parallel --coverage --min=80`;
  Targets:`Models≥95%`, `Actions/Services≥90%`, `FormRequests≥90%`, `Controllers≥85%`, `Policies≥95%`, `Overall≥80%`
}

§R{Best_Practices
  DO: factories>manual `create()`; 1_logical_assertion/test; descriptive_names(`test_guests_cannot_create_products`); test edge_cases∧authz_boundaries; fake_externals(`Http::fake()`,`Mail::fake()`); `RefreshDatabase`; `Http::preventStrayRequests()`;
  ¬DO: test Laravel_internals; inter-test_deps; over-mock(service_boundaries only); test private_methods(use public interface); couple_to_HTML_structure
}

§CHK{Verification_Loop(sequential; P1_gates_all; any_fail⇒block_release; Sail⇒prefix `./vendor/bin/sail`)
  P1_Env:`php -v && composer --version && php artisan --version && composer validate && composer dump-autoload -o` | `.env` exists∧complete; `APP_DEBUG=false`∧`APP_ENV`∈`{production,staging}`;
  P2_Lint:`vendor/bin/pint --test && vendor/bin/phpstan analyse` (⊕`vendor/bin/psalm`);
  P3_Test:`php artisan test --parallel && XDEBUG_MODE=coverage php artisan test --coverage --min=80`;
  P4_Deps:`composer audit`;
  P5_DB:`php artisan migrate --pretend && php artisan migrate:status` | audit destructive migrations∧backup first; filenames=`Y_m_d_His_*`; `down()` supports rollback;
  P6_Build:`php artisan optimize:clear && php artisan optimize` (config+route+view+event cache warmup); `storage/`∧`bootstrap/cache/` writable;
  P7_Queue:`php artisan schedule:list && php artisan queue:failed && php artisan horizon:status && php artisan queue:monitor default --max=100` (`--max=100`=backlog check only) | staging_only(queue≠`sync`): `php artisan tinker --execute="dispatch((new App\\Jobs\\QueueHealthcheck())->onQueue('healthcheck'))"` + `php artisan queue:work --once --queue=healthcheck` → verify side_effect(log|DB_row|metric);
  CI:`composer validate && composer dump-autoload -o && vendor/bin/pint --test && vendor/bin/phpstan analyse && XDEBUG_MODE=coverage php artisan test --coverage && composer audit && php artisan migrate --pretend && php artisan optimize:clear && php artisan optimize && php artisan schedule:list`
}

§REL{php-laravel.md,laravel-security.md,../../unit-testing-patterns/references/test-driven-development.md}
