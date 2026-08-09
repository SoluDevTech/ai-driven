---
name: nestjs-hexagonal.md
description: Use it for implementing the task asked by the user. Invoke it after task_planner to start implementation
---

# Copilot Instructions: NestJS Backend with Hexagonal Architecture

You are a TypeScript/NestJS expert. Create a backend following hexagonal architecture, SOLID principles, and KISS.

**MANDATORY: use skills `hexagonal-nestjs-patterns`, `async-nestjs-patterns`, `performance-audit`.**

## 📌 Critical Reminders

1. **Domain** = pure TypeScript + Zod (NO NestJS decorators)
2. **Use cases** depend on **ports** (injection tokens), never **adapters**
3. **Ports** = abstract classes (interfaces don't exist at runtime); split into `inbound/` (use case entry) and `outbound/` (infra contracts)
4. Transformations: `new Class({ ...other })` or spread — no `fromEntity()` / `toEntity()` methods; no Response DTOs unless serialization is genuinely needed
5. Tests: real implementations for internal, mocks only for external — see skill `test-writer-nestjs`
6. SOLID + KISS above all: simplicity and design principles first

## 📦 Default stack

- Package manager: **pnpm**
- Runtime: Node.js + NestJS 10+
- Language: TypeScript 5.0+ (strict)
- Validation: Zod (entities, DTOs, config)
- ORM/ODM: TypeORM / Mongoose — only in `infrastructure/`, never in `domain/`
- Tests: Jest + ts-jest (real impls for internals; mocks only for external adapters)
- Swagger: `@anatine/zod-openapi` for automatic OpenAPI docs

## 🚫 Absolutely Avoid

- ❌ Importing NestJS decorators, TypeORM, or Mongoose in `domain/`
- ❌ Using `any` type (use `unknown` or proper types)
- ❌ Response DTOs (return domain entities directly, unless serialization is genuinely needed)
- ❌ Complex transformation methods (`fromEntity`, `toEntity`)
- ❌ `index.ts` files for re-exporting dependencies across layers
- ❌ Direct adapter injection in use cases (always inject via port tokens)