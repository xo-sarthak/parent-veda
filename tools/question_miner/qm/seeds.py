"""Seed lists per stage: autocomplete stems, subreddits, and the skilling
search queries run inside general parenting subs.

Editing this file is how coverage grows. Nothing else needs to change.
"""

# Autocomplete stems. The brief's five-per-stage plus a broader set, because
# the long tail only shows up when the stem is specific enough to have one.
STEMS: dict[str, list[str]] = {
    "ttc": [
        "trying to conceive", "ovulation", "how to get pregnant", "am i pregnant",
        "miscarriage trying again",
        "ovulation test", "fertile window", "implantation bleeding", "two week wait",
        "early pregnancy symptoms before missed period", "pcos and pregnancy",
        "low amh", "sperm count", "ivf", "iui", "folic acid before pregnancy",
        "irregular periods pregnancy", "chemical pregnancy", "luteal phase",
        "conceive after 35", "conceive after miscarriage", "fertility diet",
        "when to see a fertility doctor", "cervical mucus", "basal body temperature",
    ],
    "pregnancy": [
        "pregnancy 32 weeks", "is it safe during pregnancy", "pregnancy scan",
        "morning sickness",
        "first trimester", "second trimester", "third trimester",
        "pregnancy 8 weeks", "pregnancy 12 weeks", "pregnancy 20 weeks", "pregnancy 36 weeks",
        "pregnancy diet", "foods to avoid in pregnancy", "can i eat during pregnancy",
        "pregnancy cramps", "baby movement", "gestational diabetes",
        "anomaly scan", "nt scan", "due date", "normal delivery", "c section",
        "labour pain", "pregnancy back pain", "pregnancy sleep", "pregnancy travel",
        "pregnancy exercise", "pregnancy discharge", "high risk pregnancy",
        "garbh sanskar", "pregnancy in hindi",
    ],
    "parenting": [
        "toddler not", "newborn sleep", "baby milestones", "2 year old behaviour",
        "newborn", "3 month old baby", "6 month old baby", "1 year old",
        "3 year old", "4 year old", "5 year old",
        "breastfeeding", "formula feeding", "baby weaning", "baby food",
        "toddler tantrums", "toddler sleep", "baby teething", "baby fever",
        "baby vaccination", "potty training", "baby not gaining weight",
        "toddler speech", "baby colic", "baby poop", "toddler not eating",
        "toddler hitting", "baby massage", "first 40 days after delivery",
        "postpartum", "toddler screen time",
    ],
    "skilling": [
        "teach my child to code", "improve child focus", "when should kids start reading",
        "how to build confidence in child", "kids and screen time learning",
        "coding for kids", "child concentration", "phonics for kids", "reading to kids",
        "child memory", "maths for kids", "abacus for kids", "vedic maths kids",
        "child creativity", "child communication skills", "shy child",
        "public speaking for kids", "emotional intelligence in children",
        "teach kids gratitude", "teach child values", "kids mindfulness",
        "child handwriting", "child learning", "gifted child", "child curiosity",
        "ai for kids", "robotics for kids", "chess for kids", "kids critical thinking",
        "child not interested in studies", "how to make my child intelligent",
        "brain development activities for kids", "child slow learner",
    ],
}

# Question openers prefixed to every stem for the autocomplete expansion.
# The "answer the public" trick: Google completes "<opener> <stem> ..." with
# what people actually typed after it.
QUESTION_PREFIXES = [
    "why", "how", "when", "what", "is", "can", "does", "should", "will", "do",
    "which", "who", "where", "are", "am i", "is it normal", "is it safe",
    "how to", "how long", "how much", "how many", "can i", "should i", "what if",
    "why does", "why is", "when does", "when should", "what happens",
]
# Suffix expansion letters a-z (also "answer the public").
LETTERS = [chr(c) for c in range(ord("a"), ord("z") + 1)]

# Subreddits per stage. A sub listed under one stage is collected once; the
# classifier can still move an individual title to another stage.
SUBREDDITS: dict[str, list[str]] = {
    "ttc": ["TryingForABaby", "infertility", "TFABLinePorn", "TTC30", "TTC_PCOS", "IVF",
            "Miscarriage"],
    "pregnancy": ["BabyBumps", "pregnant", "PregnancyAfterLoss", "CautiousBB", "pregnancyproblems"],
    "parenting": ["beyondthebump", "Mommit", "toddlers", "Parenting", "NewParents", "daddit",
                  "sleeptrain", "breastfeeding", "FormulaFeeders", "ScienceBasedParenting",
                  "IndianParenting", "Preschoolers"],
    "skilling": ["homeschool", "kidscoding", "Montessori", "GiftedKids", "ECEProfessionals"],
}

# Skilling is a question CONTENT, not a community, so it is also mined by
# searching general parenting subs for skill words. Titles only.
SKILLING_SEARCH_SUBS = ["Parenting", "ScienceBasedParenting", "Mommit", "daddit", "homeschool",
                        "Preschoolers"]
SKILLING_SEARCH_QUERIES = [
    "coding", "learn to read", "reading", "focus", "concentration", "confidence",
    "shy", "screen time learning", "math", "memory", "creativity", "public speaking",
    "communication skills", "emotional intelligence", "gratitude", "values",
    "curiosity", "chess", "handwriting", "gifted",
]

# Slug-based Indian community sources. Each is a sitemap that already carries
# the question text in the URL slug, so nothing but the sitemap is fetched.
INDIA_SITEMAPS = {
    "babychakra": "https://www.babychakra.com/sitemap.xml",
    "parentune_talks": "https://www.parentune.com/talks_all.xml",
    "parentune_hi_talks": "https://www.parentune.com/hi_talks.xml",
    "mylo_questions": "https://mylofamily.com/questions-sitemap.xml",
}
