# Database Migration

Master database schema and data migrations across popular ORMs. Use this skill to design, execute, and verify migrations, handle rollbacks, and achieve zero‑downtime deployments.

## When to use
- You need to change the database schema (add, rename, or modify columns).
- You must move or transform data between tables or databases.
- You are switching from one ORM to another.
- You require a reliable rollback plan.
- You aim for zero‑downtime deployments or blue‑green releases.

## Workflow
1. **Clarify goals** – list the schema changes, data transformations, target ORM, and downtime constraints.
2. **Create a backup** – dump the database or copy tables before any change.
3. **Write migration scripts** – follow the patterns for your ORM (Sequelize, TypeORM, Prisma).
4. **Wrap changes in a transaction** when the database supports it.
5. **Test on a staging environment** – run `up` and `down` scripts, verify data integrity.
6. **Deploy** – use the appropriate CLI command.
7. **Monitor** – watch logs for errors; verify the application works with the new schema.
8. **Document** – record why the change was made and how to revert it.

## ORM‑Specific Migration Patterns
### Sequelize
```javascript
// migrations/20231201-create-users.js
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('users', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      email: { type: Sequelize.STRING, unique: true, allowNull: false },
      createdAt: Sequelize.DATE,
      updatedAt: Sequelize.DATE
    });
  },
  down: async (queryInterface) => {
    await queryInterface.dropTable('users');
  }
};
```
Run: `npx sequelize-cli db:migrate`  
Rollback: `npx sequelize-cli db:migrate:undo`

### TypeORM
```typescript
// migrations/1701234567-CreateUsers.ts
import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreateUsers1701234567 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(new Table({
      name: 'users',
      columns: [
        { name: 'id', type: 'int', isPrimary: true, isGenerated: true, generationStrategy: 'increment' },
        { name: 'email', type: 'varchar', isUnique: true },
        { name: 'created_at', type: 'timestamp', default: 'CURRENT_TIMESTAMP' }
      ]
    }));
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('users');
  }
}
```
Run: `npm run typeorm migration:run`  
Rollback: `npm run typeorm migration:revert`

### Prisma
```prisma
// schema.prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  createdAt DateTime @default(now())
}
```
Generate migration: `npx prisma migrate dev --name create_users`  
Apply to production: `npx prisma migrate deploy`

## Schema Transformation Patterns
### Add Column with Default (Safe)
```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('users', 'status', {
      type: Sequelize.STRING,
      defaultValue: 'active',
      allowNull: false
    });
  },
  down: async (queryInterface) => {
    await queryInterface.removeColumn('users', 'status');
  }
};
```
### Rename Column without Downtime (Two‑Step)
1. Add new column.
2. Backfill data.
3. Deploy code that reads/writes the new column.
4. Remove old column.
```javascript
// Step 1 – add new column and copy data
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('users', 'full_name', { type: Sequelize.STRING });
    await queryInterface.sequelize.query('UPDATE users SET full_name = name');
  },
  down: async (queryInterface) => {
    await queryInterface.removeColumn('users', 'full_name');
  }
};
```
```javascript
// Step 2 – remove old column after code update
module.exports = {
  up: async (queryInterface) => {
    await queryInterface.removeColumn('users', 'name');
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('users', 'name', { type: Sequelize.STRING });
  }
};
```
### Change Column Type (Multi‑Step for Large Tables)
```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('users', 'age_new', { type: Sequelize.INTEGER });
    await queryInterface.sequelize.query(
      `UPDATE users SET age_new = CAST(age AS INTEGER) WHERE age IS NOT NULL`
    );
    await queryInterface.removeColumn('users', 'age');
    await queryInterface.renameColumn('users', 'age_new', 'age');
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.changeColumn('users', 'age', { type: Sequelize.STRING });
  }
};
```

## Data Transformation Example
```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    const [users] = await queryInterface.sequelize.query(
      'SELECT id, address_string FROM users'
    );
    for (const user of users) {
      const parts = user.address_string.split(',');
      await queryInterface.sequelize.query(
        `UPDATE users SET street = :street, city = :city, state = :state WHERE id = :id`,
        { replacements: { id: user.id, street: parts[0]?.trim(), city: parts[1]?.trim(), state: parts[2]?.trim() } }
      );
    }
    await queryInterface.removeColumn('users', 'address_string');
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('users', 'address_string', { type: Sequelize.STRING });
    await queryInterface.sequelize.query(
      `UPDATE users SET address_string = CONCAT(street, ', ', city, ', ', state)`
    );
    await queryInterface.removeColumn('users', 'street');
    await queryInterface.removeColumn('users', 'city');
    await queryInterface.removeColumn('users', 'state');
  }
};
```

## Rollback Strategies
### Transaction‑Based Migration (Atomic)
```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    const transaction = await queryInterface.sequelize.transaction();
    try {
      await queryInterface.addColumn('users', 'verified', {
        type: Sequelize.BOOLEAN,
        defaultValue: false
      }, { transaction });
      await queryInterface.sequelize.query(
        'UPDATE users SET verified = true WHERE email_verified_at IS NOT NULL',
        { transaction }
      );
      await transaction.commit();
    } catch (err) {
      await transaction.rollback();
      throw err;
    }
  },
  down: async (queryInterface) => {
    await queryInterface.removeColumn('users', 'verified');
  }
};
```
### Checkpoint‑Based Rollback (Backup Table)
```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create backup
    await queryInterface.sequelize.query('CREATE TABLE users_backup AS SELECT * FROM users');
    try {
      await queryInterface.addColumn('users', 'new_field', { type: Sequelize.STRING });
      const [result] = await queryInterface.sequelize.query(
        "SELECT COUNT(*) as cnt FROM users WHERE new_field IS NULL"
      );
      if (result[0].cnt > 0) throw new Error('Verification failed');
      await queryInterface.dropTable('users_backup');
    } catch (e) {
      // Restore from backup
      await queryInterface.sequelize.query('DROP TABLE users');
      await queryInterface.sequelize.query('CREATE TABLE users AS SELECT * FROM users_backup');
      await queryInterface.dropTable('users_backup');
      throw e;
    }
  }
};
```

## Zero‑Downtime Migration Techniques
### Blue‑Green Deployment (Backward‑Compatible Changes)
1. **Phase 1** – Add new column that does not break existing code.
2. **Phase 2** – Deploy version that writes to both old and new columns.
3. **Phase 3** – Backfill new column with existing data.
4. **Phase 4** – Deploy version that reads from the new column only.
5. **Phase 5** – Remove the old column.
```javascript
// Phase 1 – add column
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('users', 'email_new', { type: Sequelize.STRING });
  },
  down: async (queryInterface) => {
    await queryInterface.removeColumn('users', 'email_new');
  }
};
```
Repeat similar scripts for backfill and removal steps.

## Cross‑Database Migration Considerations
When the target dialect differs (e.g., PostgreSQL → MySQL), handle type differences explicitly.
```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    const dialect = queryInterface.sequelize.getDialect();
    const jsonType = dialect === 'postgres' ? Sequelize.JSONB : Sequelize.JSON;
    await queryInterface.createTable('users', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      data: { type: jsonType }
    });
  }
};
```
Test the script against both dialects before production.

## Production Rules
1. **Every change is a migration.** Do not change a production database by hand.
2. **Production migrations go forward only.** To roll back, write a new forward migration.
3. **Keep schema and data migrations separate.** Do not mix DDL and DML in one migration.
4. **Test on production-sized data.** A migration that is fast on 100 rows can lock a table with 10M rows.
5. **Do not edit a migration after it ran in production.** Write a new one.

Safety checklist before you apply a migration:
- [ ] It has UP and DOWN, or it is marked as irreversible
- [ ] No full table lock on a large table (use concurrent operations)
- [ ] New columns are nullable or have a default
- [ ] Indexes on existing tables are created concurrently
- [ ] The data backfill is a different migration from the schema change
- [ ] Tested on a copy of production data, with a written rollback plan

## PostgreSQL Patterns
```sql
-- Add a column: nullable is instant
ALTER TABLE users ADD COLUMN avatar_url TEXT;
-- A constant default is instant on PostgreSQL 11+ (no table rewrite)
ALTER TABLE users ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;
-- BAD: NOT NULL without a default fails on a table that has rows; add nullable, backfill, then set NOT NULL
ALTER TABLE users ADD COLUMN role TEXT NOT NULL;

-- Index without blocking writes (cannot run inside a transaction block)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users (email);

-- Remove a column: first remove all code references and deploy, then drop it in the next migration
ALTER TABLE orders DROP COLUMN legacy_status;
```

Batched backfill (do not update all rows in one transaction):
```sql
-- PostgreSQL 11+: COMMIT in a DO block works only when the block runs outside a transaction
DO $$
DECLARE
  batch_size INT := 10000;
  rows_updated INT;
BEGIN
  LOOP
    UPDATE users SET normalized_email = LOWER(email)
    WHERE id IN (
      SELECT id FROM users WHERE normalized_email IS NULL
      LIMIT batch_size FOR UPDATE SKIP LOCKED
    );
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    RAISE NOTICE 'Updated % rows', rows_updated;
    EXIT WHEN rows_updated = 0;
    COMMIT;
  END LOOP;
END $$;
```

## More Tool Workflows
### Prisma: custom SQL
Prisma cannot generate `CREATE INDEX CONCURRENTLY` or data backfills. Create an empty migration and write the SQL:
```bash
npx prisma migrate dev --create-only --name add_email_index
```
```sql
-- prisma/migrations/20240115_add_email_index/migration.sql
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users (email);
```
Prisma runs each migration file in a transaction by default. Put a `CONCURRENTLY` statement in its own migration file, and do not mix it with other statements.

### Drizzle
```bash
npx drizzle-kit generate   # Create a migration from schema changes
npx drizzle-kit migrate    # Apply migrations
npx drizzle-kit push       # Dev only: push the schema with no migration file
```
For more, see `drizzle-orm.md`.

### Kysely (kysely-ctl)
```bash
kysely migrate make add_user_avatar
kysely migrate latest
kysely migrate down
kysely migrate list
```
```typescript
// migrations/2024_01_15_001_create_user_profile.ts
import { type Kysely, sql } from 'kysely'

// Use Kysely<any>, not the typed DB interface. A migration must not depend on the current schema types.
export async function up(db: Kysely<any>): Promise<void> {
  await db.schema
    .createTable('user_profile')
    .addColumn('id', 'serial', (col) => col.primaryKey())
    .addColumn('email', 'varchar(255)', (col) => col.notNull().unique())
    .addColumn('avatar_url', 'text')
    .addColumn('created_at', 'timestamp', (col) => col.defaultTo(sql`now()`).notNull())
    .execute()
}

export async function down(db: Kysely<any>): Promise<void> {
  await db.schema.dropTable('user_profile').execute()
}
```
For a programmatic run, use `new Migrator({ db, provider: new FileMigrationProvider({ fs, path, migrationFolder }) })` and `migrateToLatest()`. Stop the process when it returns `error`. Do not set `allowUnorderedMigrations` outside development.

### Django
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py showmigrations
python manage.py makemigrations --empty app_name -n description   # For custom SQL or data
```
```python
from django.db import migrations

def backfill_display_names(apps, schema_editor):
    User = apps.get_model("accounts", "User")   # Historical model, not a direct import
    qs = User.objects.filter(display_name="")
    while batch := list(qs[:5000]):
        for u in batch:
            u.display_name = u.username
        User.objects.bulk_update(batch, ["display_name"])

class Migration(migrations.Migration):
    dependencies = [("accounts", "0015_add_display_name")]
    operations = [migrations.RunPython(backfill_display_names, migrations.RunPython.noop)]
```
To remove a field from the model but keep the column for one more deploy:
```python
migrations.SeparateDatabaseAndState(
    state_operations=[migrations.RemoveField(model_name="user", name="legacy_field")],
    database_operations=[],   # Drop the column in a later migration
)
```

### golang-migrate
```bash
migrate create -ext sql -dir migrations -seq add_user_avatar
migrate -path migrations -database "$DATABASE_URL" up
migrate -path migrations -database "$DATABASE_URL" down 1
migrate -path migrations -database "$DATABASE_URL" force VERSION   # Fix a dirty state
```
```sql
-- 000003_add_user_avatar.up.sql
ALTER TABLE users ADD COLUMN avatar_url TEXT;
-- 000003_add_user_avatar.down.sql
ALTER TABLE users DROP COLUMN IF EXISTS avatar_url;
```

## Expand-Contract Timeline
```
Day 1: Migration adds new_status (nullable)
Day 1: Deploy app v2, which writes to status and new_status
Day 2: Backfill migration for existing rows, then check consistency
Day 3: Deploy app v3, which reads and writes only new_status
Day 7: Migration drops the old status column
```

| Anti-pattern | Why it fails | Better approach |
|---|---|---|
| Manual SQL in production | No audit trail, cannot repeat | Migration files only |
| Edit a deployed migration | Environments drift | Write a new migration |
| NOT NULL with no default | Fails or rewrites the table | Nullable, backfill, then add the constraint |
| Inline index on a large table | Blocks writes | `CREATE INDEX CONCURRENTLY` |
| Schema and data in one migration | Long transactions, hard rollback | Separate migrations |
| Drop a column before the code stops using it | Errors for a missing column | Remove code first, drop in the next deploy |

## Best Practices
1. **Provide a down migration** for every up migration.
2. **Test on staging** before applying to production.
3. **Use transactions** when the database supports them.
4. **Backup data** before any destructive change.
5. **Make incremental changes**; avoid large monolithic migrations.
6. **Monitor logs** during and after deployment.
7. **Document intent** – why the change is needed and how to revert it.
8. **Ensure idempotence** – running the same migration twice should not fail.

## Common Pitfalls
- Skipping rollback tests; the down script may fail.
- Introducing breaking schema changes without a zero‑downtime plan.
- Ignoring NULL handling when adding non‑nullable columns.
- Overlooking index impact on large tables.
- Forgetting foreign‑key constraints during column rename.
- Migrating too much data in a single transaction, causing timeouts.

## Checklist
- [ ] Define migration goal and scope.
- [ ] Create a full database backup.
- [ ] Write up and down scripts following ORM patterns.
- [ ] Wrap changes in a transaction if possible.
- [ ] Test migration on a copy of production data.
- [ ] Verify data integrity after `up`.
- [ ] Verify that `down` restores the original state.
- [ ] Deploy using the appropriate CLI command.
- [ ] Monitor application logs for errors.
- [ ] Update documentation with migration details.

## Related skills

Load these when the task spans more than this skill.

- [`database-design`](../SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-optimization`](database-optimization.md) — Expert database optimization for SQL and NoSQL systems. Use for query tuning, indexing strategies, performance…
- [`prisma`](prisma.md) — Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation…
- [`backend-development`](../../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
