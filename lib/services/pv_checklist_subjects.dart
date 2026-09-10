// =============================================================================
//  pvChecklistSubjectStores — the stores a checklist's subject reads
// -----------------------------------------------------------------------------
//  ⚠️ ONE LIST, SO THE SCREEN DOES NOT HAVE TO KNOW WHICH DOOR IT IS ON.
//
//  `PvChecklist.subject()` derives what a checklist is about from the area's
//  own store — the scans one reads `ScansStore`, the conditions one reads
//  `ConditionsStore`. The screen renders both and must rebuild when either
//  changes, or the heading goes stale in place: a scan marked done, or a
//  condition added, and the title still names the old one.
//
//  ⚠️ THE ALTERNATIVE WAS A `Listenable` FIELD ON `PvChecklist`, and it is
//  worse in a way worth naming. A data file would then hold a live object
//  rather than a description, every checklist would have to remember to declare
//  its own dependency, and forgetting is invisible — the screen simply does not
//  update, which looks like nothing.
//
//  Merging every subject store instead is a rebuild or two nobody will notice
//  on a screen with twenty checkboxes, and it cannot be forgotten. When a door
//  adds a checklist whose subject reads a new store, it is one line here.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../data/conditions_data.dart' show ConditionsStore;
import 'scans_store.dart';

/// Every store a `PvChecklist.subject` reads today.
List<Listenable> get pvChecklistSubjectStores => [
      ScansStore.instance,
      ConditionsStore.instance,
    ];
