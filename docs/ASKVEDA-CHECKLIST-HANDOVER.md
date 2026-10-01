# Ask Veda: what she has covered in her checklist (handover to the service repo)

Written 2026-10-01. **The app half is done and inert until the service half lands.**
Per CLAUDE.md this repo cannot change the service (`C:\Projects\parentveda-askveda`),
and a field the service does not declare is ignored. It logs the unknown field, so
you will see `ttc_checklist` in its console until this is built.

## What the app now sends

On `POST /ask`, from the Trying to Conceive Ask Veda screen only, from HER device
only (never from the partner's), and only when she has answered something:

```json
"ttc_checklist": {
  "covered": ["folate", "tobacco", "vaccines_rubella"],
  "flagged": ["supplement_review", "thyroid"]
}
```

- `covered`: ids of checklist items she has settled as done (her own answer;
  a tick the app inferred from her records is not included).
- `flagged`: ids she marked "need to do" or "not sure".
- **Ids only.** Never her notes, never free text. The ids are the stable item ids in
  `lib/ttc/ttc_precheck_data.dart` (`kPrecheckItems`); the app owns the list.

## What the service should do with it (framing only, never a filter)

1. Declare an optional `ttc_checklist` object on the ask request model
   (`covered: list[str]`, `flagged: list[str]`, both default empty).
2. **Do not tell her to start what she already has covered.** If the question is
   about folic acid and `folate` is in `covered`, answer without "you should
   start folic acid".
3. **For a flagged item, say it is worth raising with her doctor**, in the same
   calm voice as the rest; never a diagnosis, never a drug to ask for.
4. **Cache key**: this changes the framing, so it must be part of the bucket or two
   mothers with different checklists would share one cached answer. Bucket on a
   coarse form (for example the sorted set of ids that are relevant to the
   question's topic), not on the full lists, or the cache never hits.
5. Do not log the lists in analytics beyond the usual request log; they are health
   answers.

## Why ids and not text

Ids carry no free text, so there is nothing of hers to leak or to mis-parse, and the
service can ignore any id it does not know. The cost is that the service needs the
item list to give an id any meaning. It can mirror `kPrecheckItems` (id and title),
or only the handful of ids it wants to act on.

## Closing this

When the service half ships, delete the "inert" notes in
`lib/services/remote/ask_veda_service.dart` (the `ttcChecklist` doc comment) and in
`lib/screens/ttc/ttc_askveda_screen.dart`, and add the date here.
