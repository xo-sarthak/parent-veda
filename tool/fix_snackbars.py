"""Route the remaining raw SnackBar / error literals through the string table.

These are the last English on the pregnancy side. They survived every earlier
pass because a SnackBar lives for three seconds and nobody screenshots one -
which is also why they matter: they are where a mother is most often being told
something failed.
"""

import os
import re

# (file, exact source snippet, replacement)
EDITS = [
    ('lib/brand/launch_hub_screen.dart',
     "'${r.label} — coming soon'", 'S.now.comingSoonLabel(r.label)'),
    ('lib/screens/auth/auth_flow_screen.dart',
     "'$label - coming soon'", 'S.now.comingSoonLabel(label)'),
    ('lib/screens/prepare/prepare_common.dart',
     "'$what opens soon'", 'S.now.opensSoon(what)'),
    ('lib/screens/profile_screen.dart',
     "'WhatsApp updates on'", 'S.now.whatsappUpdatesOn'),
    ('lib/screens/profile_screen.dart',
     "'WhatsApp updates off'", 'S.now.whatsappUpdatesOff'),
    ('lib/screens/profile_screen.dart',
     "'Could not save - please try again'", 'S.now.couldNotSaveRetry'),
    ('lib/screens/tools/ask_veda_screen.dart',
     "'This video is coming soon'", 'S.now.videoComingSoon'),
    ('lib/screens/product_guide/product_guide_screen.dart',
     "'This explainer is still being filmed.'", 'S.now.explainerBeingFilmed'),
    ('lib/brand/sampling_screen.dart',
     "'Sign in first, so we know where to send it.'",
     'S.now.signInFirstToSend'),
    ('lib/brand/sampling_screen.dart',
     "'Could not save that — check your connection and try again.'",
     'S.now.couldNotSaveConnection'),
    ('lib/screens/memories/memory_preview_screen.dart',
     "'Saved to your gallery and My Memories.'",
     'S.now.savedToGalleryAndMemories'),
    ('lib/screens/memories/memory_preview_screen.dart',
     "'Saved to My Memories. Allow photo access to save to your gallery.'",
     'S.now.savedToMemoriesAllowPhoto'),
    ('lib/screens/memories/memory_preview_screen.dart',
     "'Could not prepare the image. Try again.'",
     'S.now.couldNotPrepareImage'),
    ('lib/screens/memories/memory_personalize_screen.dart',
     "'Could not add photo: $e'", 'S.now.couldNotAddPhoto(e)'),
    ('lib/referral/referral_engine.dart',
     "'This referral offer is not running right now'",
     'S.now.referralNotRunning'),
    ('lib/referral/referral_engine.dart',
     "'You have hit today\\'s invite limit. Try again tomorrow.'",
     'S.now.inviteLimitToday'),
    ('lib/referral/referral_engine.dart',
     "'You have hit this month\\'s invite limit.'", 'S.now.inviteLimitMonth'),
    ('lib/referral/referral_engine.dart',
     "'You have earned the maximum rewards for this campaign.'",
     'S.now.maxRewardsEarned'),
]


def relative_import(path):
    rel = os.path.relpath('lib/localization/app_language.dart',
                          os.path.dirname(path)).replace(os.sep, '/')
    return f"import '{rel}';"


touched, missed = {}, []
for path, old, new in EDITS:
    src = touched.get(path) or open(path, encoding='utf-8').read()
    if old not in src:
        missed.append((path, old))
        touched[path] = src
        continue
    touched[path] = src.replace(old, new)

for path, src in touched.items():
    if 'S.now.' in src and 'localization/app_language.dart' not in src:
        imports = list(re.finditer(r"^import .*;$", src, re.M))
        at = imports[-1].end() if imports else 0
        src = src[:at] + '\n' + relative_import(path) + src[at:]
    open(path, 'w', encoding='utf-8', newline='').write(src)

print(f'{len(EDITS) - len(missed)}/{len(EDITS)} replaced')
for path, old in missed:
    print(f'  MISS  {path}\n        {old[:70]}')
