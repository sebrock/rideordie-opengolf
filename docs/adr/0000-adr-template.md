# ADR 0000: <Decision Title>

- **Status:** Proposed | Accepted | Superseded | Deprecated | Rejected
- **Date:** YYYY-MM-DD
- **Decision owners:** <names / GitHub handles>
- **Reviewers:** <names / GitHub handles>
- **Related issues / PRs:** #<issue>, #<pr>
- **Supersedes:** ADR <number> | N/A
- **Superseded by:** ADR <number> | N/A

---

## Context

Describe the problem, constraint, or opportunity that requires an architectural decision.

Include enough background for a future contributor to understand why this decision mattered at the time.

Cover, where relevant:

- Product requirement or user story
- Technical constraint
- Nostr / Bitcoin / Lightning dependency
- Open-source requirement
- Data ownership or portability concern
- Operational or event-readiness concern
- Security or privacy concern
- Accessibility or UX concern

---

## Decision

State the decision clearly.

Use direct language:

> We will ...

Then summarize the implementation direction:

- Component / service affected:
- Interfaces / APIs affected:
- Data model changes:
- Deployment changes:
- Documentation changes:

---

## Alternatives Considered

### Alternative 1: <Name>

**Summary:**  
<Describe the alternative.>

**Pros:**

- ...

**Cons:**

- ...

**Reason not chosen:**  
<Explain why this was not selected.>

### Alternative 2: <Name>

**Summary:**  
<Describe the alternative.>

**Pros:**

- ...

**Cons:**

- ...

**Reason not chosen:**  
<Explain why this was not selected.>

### Do Nothing / Defer

**Summary:**  
<Describe what happens if no decision is made now.>

**Trade-off:**  
<Explain whether delay is acceptable or risky.>

---

## Trade-offs

Document the consequences of the decision.

### Benefits

- ...

### Costs

- ...

### Risks

- ...

### Operational Impact

- ...

### User Impact

- ...

### Developer Impact

- ...

---

## License Review

This project is open-source-first. Any dependency, API, dataset, asset, or protocol integration introduced by this ADR must be license-compatible with the project.

- **License review required:** Yes | No
- **New dependencies introduced:** Yes | No
- **New data source introduced:** Yes | No
- **New visual/audio/content asset introduced:** Yes | No
- **License(s):** <MIT / Apache-2.0 / GPL-3.0 / AGPL-3.0 / ODbL / CC BY / unknown / other>
- **Commercial use allowed:** Yes | No | Unknown
- **Attribution required:** Yes | No | Unknown
- **Share-alike obligations:** Yes | No | Unknown
- **Copyleft impact:** None | Weak | Strong | Unknown
- **Reviewer:** <name / GitHub handle>
- **Review outcome:** Approved | Changes requested | Rejected | Pending

### License Notes

<Add details, links to license files, attribution requirements, or unresolved concerns.>

---

## Security Review

Any decision touching identity, signing, wallet connectivity, payments, score attestation, user-generated content, admin controls, or data ingestion should receive security review.

- **Security review required:** Yes | No
- **Touches Nostr keys/signing:** Yes | No
- **Touches wallet / Lightning / NWC flows:** Yes | No
- **Touches payments, zaps, rewards, or balances:** Yes | No
- **Touches authentication or authorization:** Yes | No
- **Touches score attestation or trust model:** Yes | No
- **Touches user-generated content or moderation:** Yes | No
- **Touches external data ingestion or scraping:** Yes | No
- **Touches secrets, tokens, or infrastructure credentials:** Yes | No
- **Reviewer:** <name / GitHub handle>
- **Review outcome:** Approved | Changes requested | Rejected | Pending

### Threats Considered

- ...

### Mitigations

- ...

### Residual Risk

<Describe what risk remains after mitigation.>

---

## Rollback Plan

Describe how the decision can be reversed or disabled if it causes problems.

- **Rollback trigger:** <What condition means we roll back?>
- **Rollback owner:** <name / GitHub handle>
- **Rollback complexity:** Low | Medium | High
- **Feature flag available:** Yes | No | N/A
- **Data migration reversible:** Yes | No | N/A
- **User communication needed:** Yes | No
- **Operational steps:**
  1. ...
  2. ...
  3. ...

### Fallback Behavior

<What should users see or experience if this feature/component is disabled?>

---

## Implementation Plan

Break the decision into implementation steps.

- [ ] Create / update issues
- [ ] Update documentation
- [ ] Implement feature or architectural change
- [ ] Add tests
- [ ] Complete license review, if required
- [ ] Complete security review, if required
- [ ] Complete UX/accessibility review, if required
- [ ] Update deployment / operations notes
- [ ] Confirm rollback path

---

## Validation

How will we know this decision works?

- **Acceptance criteria:**
  - ...
- **Test coverage:**
  - ...
- **Manual verification:**
  - ...
- **Event-readiness check:**
  - ...

---

## Follow-up Decisions

List related questions that are not resolved by this ADR.

- ...

---

## References

Add links to relevant issues, PRs, specs, NIPs, documentation, licenses, or prior art.

- ...
