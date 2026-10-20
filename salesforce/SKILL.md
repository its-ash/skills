---
name: salesforce
description: "Provides Salesforce development patterns for Lightning Web Components, bulkified Apex triggers with handler classes, Queueable Apex, SOQL queries, governor limits, and safe deployment checklists. Use when building, debugging, or refactoring LWC, Apex classes, triggers, batch jobs, async processing, Salesforce metadata, SFDX projects, .cls, .trigger, .js, .html, .xml files, sf or sfdx commands, System.LimitException, DMLException, or org automation."
---

# Salesforce Development

Develop on the Salesforce platform using proven patterns. Follow the guidance to write performant LWC, bulk‑safe Apex triggers, and reliable asynchronous jobs while avoiding common pitfalls.

## When to use
- Building a user interface with Lightning Web Components.
- Implementing business logic that runs on record insert, update, delete, or undelete.
- Running long‑running or batch work that must not block the transaction.
- Creating or maintaining a managed package or scratch‑org‑based project.

## Patterns

### Lightning Web Component with `@wire`
- Use `@wire` to bind data reactively from Lightning Data Service or Apex.
- Keep the component stateless; let the framework handle caching and refresh.

```html
<!-- myComponent.html -->
<template>
  <lightning-card title="Account List">
    <template if:true={accounts.data}>
      <ul>
        <template for:each={accounts.data} for:item="acc">
          <li key={acc.Id}>{acc.Name}</li>
        </template>
      </ul>
    </template>
    <template if:true={accounts.error}>
      <p>{accounts.error}</p>
    </template>
  </lightning-card>
</template>
```
```js
// myComponent.js
import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class MyComponent extends LightningElement {
  @wire(getAccounts) accounts; // Reactive, cached, refreshed automatically
}
```
- Do not call Apex imperatively unless you need to pass parameters or handle errors manually.

### Bulkified Apex Trigger with Handler Pattern
- Keep the trigger thin; delegate all logic to a handler class.
- Process records in collections, never inside a loop.
- Prevent recursion with a static flag.

```apex
// AccountTrigger.trigger
trigger AccountTrigger on Account (before insert, before update, after delete) {
    if (Trigger.isBefore) {
        AccountTriggerHandler.handleBefore(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        AccountTriggerHandler.handleAfterDelete(Trigger.old);
    }
}
```
```apex
// AccountTriggerHandler.cls
public class AccountTriggerHandler {
    private static Boolean isRunning = false;

    public static void handleBefore(List<Account> newRecs) {
        if (isRunning) return; // recursion guard
        isRunning = true;
        // Example bulk logic: set a default field
        for (Account a : newRecs) {
            if (a.Custom_Field__c == null) {
                a.Custom_Field__c = 'Default';
            }
        }
        isRunning = false;
    }

    public static void handleAfterDelete(List<Account> oldRecs) {
        // Bulk delete logic, e.g., cleanup related records
        List<Child__c> children = [SELECT Id FROM Child__c WHERE ParentId IN :oldRecs];
        delete children;
    }
}
```
- Use `Set<Id>` for look‑ups; query once per transaction.
- Respect the 200‑record limit per trigger invocation.

### Queueable Apex for Asynchronous Processing
- Choose Queueable when you need to pass complex objects or chain jobs.
- Enqueue with `System.enqueueJob(new MyJob(param));`.
- Limit: 50 jobs per transaction, one child job per parent when chaining.

```apex
public class MyJob implements Queueable, Database.AllowsCallouts {
    private List<Id> recordIds;

    public MyJob(List<Id> ids) {
        this.recordIds = ids;
    }

    public void execute(QueueableContext ctx) {
        // Example: callout for each record, respecting callout limits
        for (Id recId : recordIds) {
            // perform HTTP callout or heavy computation
        }
        // Chain another job if needed
        // System.enqueueJob(new FollowUpJob(...));
    }
}
```
- Monitor jobs via `AsyncApexJob` object.
- Avoid DML inside a loop; batch records into a single `insert/update/delete` statement.

## Anti‑Patterns
- **SOQL inside loops** – moves the query out of the loop; query once, store results in a map.
- **DML inside loops** – collect records and perform a single DML operation after the loop.
- **Hard‑coding IDs** – store IDs in Custom Settings, Custom Metadata, or use `Schema.getGlobalDescribe()`.
- **Mixed DML** – do not perform setup‑object DML (e.g., User) and non‑setup DML in the same transaction.
- **Recursive trigger calls** – use a static Boolean flag or `Trigger.isExecuting` guard.

## Sharp Edges / Gotchas
- **Governor limits** – CPU time, heap size, SOQL rows, and callouts have strict caps. Write bulk‑safe code and test with large data sets.
- **Async limits** – only 250,000 Queueable jobs per 24‑hour period per org.
- **Lightning Data Service caching** – changes made by Apex may not instantly reflect in LWC; use `refreshApex` when needed.
- **Bulk‑only fields** – some fields (e.g., `OwnerId` on certain objects) cannot be set in bulk; handle them individually.
- **Package versioning** – when using 2GP, lock down API version and run `sfdx force:package:version:create` for each release.

## Checklist
- [ ] Use `@wire` for read‑only data; use imperative Apex only when parameters are required.
- [ ] Keep triggers under 10 lines; delegate to a handler class.
- [ ] Query once, store results in maps, and avoid loops with SOQL/DML.
- [ ] Guard against recursion with a static flag.
- [ ] Use Queueable Apex for callouts or heavy processing; respect job limits.
- [ ] Store configurable IDs in Custom Metadata, not in code.
- [ ] Write unit tests covering bulk scenarios (≥200 records).
- [ ] Verify governor limits with `Limits` class in tests.
- [ ] Refresh LWC data after async updates using `refreshApex`.
- [ ] Document any sharp‑edge behavior in the class comments.

## Related skills

Load these when the task spans more than this skill.

- [`java`](../java/SKILL.md) — Guidance, best practices, and checklists for modern Java 21+ development, covering language features, virtual…
- [`javascript`](../javascript/SKILL.md) — A concise reference of core JavaScript concepts—primitives, type coercion, scope, closures, this, event loop,…
- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`lead-research`](../lead-research/SKILL.md) — Lead Research skill finds and qualifies high‑quality prospects for a product or service. Provide product detai…
