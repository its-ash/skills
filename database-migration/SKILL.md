---
name: database-migration
description: "Guides database schema and data migrations across Sequelize, TypeORM, and Prisma with safe column additions, renames, type changes, data backfills, and zero-downtime patterns like expand-contract and dual-write. Use when running npx sequelize db:migrate, npx typeorm migration:run, or npx prisma migrate deploy, executing ALTER TABLE for NOT NULL columns with defaults, two-step column renames, varchar-to-text changes on large tables, UPDATE backfills, BEGIN TRANSACTION atomic blocks, backup-table checkpoints, PostgreSQL MySQL SQLite dialect handling, and rollback scripts after failed deployments."
---

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

- [`database-design`](../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-optimization`](../database-optimization/SKILL.md) — Expert database optimization for SQL and NoSQL systems. Use for query tuning, indexing strategies, performance…
- [`prisma`](../prisma/SKILL.md) — Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation…
- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`dotnet`](../dotnet/SKILL.md) — Provides guidance, patterns, and checklists for modern C# development and ASP.NET Core backend services, cover…
- [`neon-postgres`](../neon-postgres/SKILL.md) — Provision and manage Neon Serverless Postgres databases. Covers instant provisioning via Instagres (npx get-db…
