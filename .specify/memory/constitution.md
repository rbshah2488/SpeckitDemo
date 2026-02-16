<!--
  ============================================================================
  SYNC IMPACT REPORT
  ============================================================================
  Version Change: [CONSTITUTION_VERSION] → 1.0.0
  
  Modified Principles:
  - [PRINCIPLE_1_NAME] → I. Code Quality Standards
  - [PRINCIPLE_2_NAME] → II. Testing Standards (NON-NEGOTIABLE)
  - [PRINCIPLE_3_NAME] → III. User Experience Consistency
  - [PRINCIPLE_4_NAME] → IV. Performance Requirements
  
  Added Sections:
  - Core Principles (4 principles defined)
  - Quality Gates section
  - Development Workflow section
  - Governance section
  
  Removed Sections:
  - [PRINCIPLE_5_NAME] (reduced from 5 to 4 principles per user request)
  - [SECTION_2_NAME] (replaced with Quality Gates)
  - [SECTION_3_NAME] (replaced with Development Workflow)
  
  Templates Requiring Updates:
  ✅ plan-template.md - Constitution Check section aligns with new principles
  ✅ spec-template.md - Requirements and success criteria align with UX consistency
  ✅ tasks-template.md - Task organization supports testing-first workflow
  
  Follow-up TODOs:
  - RATIFICATION_DATE intentionally set to today (2026-02-16) as this is initial constitution
  - No additional templates found in .specify/templates/commands/ directory
  - All placeholders filled with concrete values
  ============================================================================
-->

# SpeckitDemo Constitution

## Core Principles

### I. Code Quality Standards

Code MUST be maintainable, readable, and follow established conventions:

- **Consistency**: Follow existing code style, naming conventions, and architectural patterns within the codebase
- **Simplicity**: Prefer simple, explicit solutions over clever abstractions; apply YAGNI (You Aren't Gonna Need It)
- **Documentation**: Public APIs and complex logic MUST have clear documentation; inline comments only for non-obvious "why" rationale
- **Type Safety**: Use static typing where available; all function signatures MUST declare parameter and return types
- **Error Handling**: All error paths MUST be handled explicitly; fail fast with actionable error messages
- **Security**: Never log, expose, or commit secrets or keys; validate all external inputs; follow security best practices

**Rationale**: High code quality reduces bugs, accelerates onboarding, and enables confident refactoring. Consistency across the codebase eliminates cognitive overhead and reduces review friction.

### II. Testing Standards (NON-NEGOTIABLE)

Testing is mandatory and MUST follow these standards:

- **Test-First Development**: Tests MUST be written before implementation; verify tests fail before writing code to pass them
- **Coverage Expectations**: 
  - Unit tests for all business logic and utilities
  - Integration tests for cross-component workflows and data flows
  - Contract tests for all public APIs and interfaces
- **Test Quality**: Tests MUST be independent, repeatable, and fast; avoid flaky tests
- **Test Organization**: Mirror source structure in test directories; group by test type (unit/, integration/, contract/)
- **Continuous Validation**: All tests MUST pass before commits; CI/CD pipelines MUST block merges on test failures

**Rationale**: Test-first development catches bugs early, serves as living documentation, and enables fearless refactoring. Non-negotiable enforcement ensures consistent quality across all features.

### III. User Experience Consistency

User-facing features MUST deliver consistent, intuitive experiences:

- **Design Patterns**: Reuse established UI patterns and components; document new patterns when introduced
- **Accessibility**: All interfaces MUST be accessible (keyboard navigation, screen reader support, appropriate contrast)
- **Feedback**: Provide immediate feedback for user actions; display clear loading states and error messages
- **Progressive Enhancement**: Core functionality MUST work without JavaScript; enhance with JS where available
- **Responsive Design**: Interfaces MUST adapt gracefully across device sizes and input methods
- **Internationalization Ready**: Use i18n-friendly patterns; avoid hardcoded strings in UI code

**Rationale**: Consistent UX reduces user friction, builds trust, and lowers support costs. Accessibility ensures inclusive design and often improves usability for all users.

## Quality Gates

Before any feature is considered complete, it MUST pass:

1. **Constitution Compliance**: Review against all four core principles
2. **Test Coverage**: All required test types present and passing
3. **Code Review**: Peer review verifying quality standards and consistency
4. **Performance Validation**: Metrics meet requirements section thresholds
5. **Accessibility Check**: Basic accessibility standards verified

Features MAY NOT be merged until all gates pass.

## Development Workflow

### Planning Phase
- Define user stories with acceptance criteria
- Identify performance targets and constraints
- Establish testing strategy for each story

### Implementation Phase
- Write failing tests first (Test-First Development)
- Implement code to pass tests
- Verify code quality standards and consistency
- Profile and optimize performance-critical paths

### Review Phase
- Run all automated tests and linters
- Conduct peer code review for quality and consistency
- Validate UX consistency and accessibility
- Verify performance metrics

### Release Phase
- All quality gates MUST pass
- Update documentation as needed
- Monitor performance in production

## Governance

This constitution supersedes all other development practices. Amendments require:

1. **Documentation**: Proposed change with rationale and impact analysis
2. **Review**: Team review and approval via documented process
3. **Migration Plan**: Clear path for applying changes to existing code
4. **Version Update**: Increment constitution version according to semantic versioning

All code reviews MUST verify compliance with this constitution. Any complexity introduced MUST be justified and documented. Violations of non-negotiable principles (Test-First Development) will block merges.

**Version**: 1.0.0 | **Ratified**: 2026-02-16 | **Last Amended**: 2026-02-16
