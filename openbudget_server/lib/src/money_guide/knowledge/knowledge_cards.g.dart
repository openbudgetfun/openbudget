// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: dart run tool/generate_knowledge.dart
//
// Source of truth: knowledge/<country>/<topic>/<card>.md,
// one file per card (docs/money-guide.md, sections 4.1
// and 4.2).

import 'package:openbudget_core/openbudget_core.dart';

import 'knowledge_card.dart';

/// Every knowledge card, in file-path order.
/// A top-level final: the corpus is built once, on first use.
final List<KnowledgeCard> knowledgeCards = <KnowledgeCard>[
  KnowledgeCard(
    id: "universal-budgeting-sinking-funds",
    countryCode: "universal",
    title: "Sinking funds spread the cost of known one-off expenses",
    topics: const <String>["budgeting", "sinking-funds"],
    entityKinds: <EntityKind>[EntityKind.individual, EntityKind.soleTrader],
    taxYears: <int>[],
    grade: TaxEvidenceGrade.primary,
    verifiedOn: DateTime.utc(2026, 11, 13),
    recheckBy: DateTime.utc(2027, 5, 31),
    perimeter: KnowledgePerimeter.general,
    needsEvidence: false,
    announced: false,
    keywords: const <String>["sinking fund", "annual bills", "irregular expenses", "car tax", "insurance renewal", "Christmas saving", "holiday fund", "spread the cost"],
    sources: <KnowledgeCardSource>[
      KnowledgeCardSource(
        title: "MoneyHelper, Sinking funds explained",
        url: Uri.https("www.moneyhelper.org.uk", "/en/blog/everyday-money/sinking-funds-explained"),
        grade: TaxEvidenceGrade.primary,
      ),
    ],
    body: "A sinking fund is a pot set aside for an expense that is known but not\nmonthly. MoneyHelper describes it as money paid into regularly for an\nexpense that is coming: an annual insurance bill, the car's MOT, school\nuniforms, holidays or celebrations. Spreading the cost keeps the month the\nbill lands from becoming a crunch.\n\nThe arithmetic is the total cost divided by the months left. A £480\ninsurance renewal due in eight months needs £60 set aside each month, so\nthe envelope holds the full amount by the time the bill arrives. Anything\nalready in the envelope reduces the monthly figure by its share.\n\nSinking funds differ from an emergency fund in what they pay for: the\nsinking fund covers costs that are known, and the emergency fund covers\ncosts that are not. MoneyHelper notes that a fund built from scratch starts\nwith the emergency pot first, because a broken boiler cannot be scheduled.",
  ),
  KnowledgeCard(
    id: "universal-budgeting-zero-based-envelopes",
    countryCode: "universal",
    title: "Zero-based envelopes give every unit of income a job",
    topics: const <String>["budgeting"],
    entityKinds: <EntityKind>[],
    taxYears: <int>[],
    grade: TaxEvidenceGrade.primary,
    verifiedOn: DateTime.utc(2026, 11, 13),
    recheckBy: DateTime.utc(2027, 5, 31),
    perimeter: KnowledgePerimeter.general,
    needsEvidence: false,
    announced: false,
    keywords: const <String>["zero-based budgeting", "envelopes", "give every unit a job", "standing start", "income minus expenses", "budget method", "allocate income"],
    sources: <KnowledgeCardSource>[
      KnowledgeCardSource(
        title: "CFPB, Budgeting: how to create a budget and stick with it",
        url: Uri.https("www.consumerfinance.gov", "/archive/blog/budgeting-how-to-create-a-budget-and-stick-with-it/"),
        grade: TaxEvidenceGrade.primary,
      ),
    ],
    body: "Zero-based budgeting means income minus assigned expenses equals zero at the\nstart of the month. In OpenBudget it happens with envelopes: each envelope\nholds money for one kind of spending, and assigning continues until no\nincome is left unassigned. The assignment is a plan, not a payment — money\nmoves between envelopes whenever the plan changes.\n\nA standing start follows three steps. First, list the income the month will\nbring. Second, fill envelopes for the costs the month will actually meet,\nstarting with obligations such as rent, utilities and food, then the\nirregular costs, then goals and wants. Third, check the arithmetic: the\nenvelopes together hold exactly what the income provides, so an overfilled\nplan shows up as a shortfall now rather than as debt later.\n\nThe US Consumer Financial Protection Bureau describes the same method\nwithout envelopes: record income, record spending, and build a budget from\nthe two until income minus spending is a deliberate number, then update it\nwhen income or habits change.",
  ),
  KnowledgeCard(
    id: "universal-crypto-crypto-tax-reporting",
    countryCode: "universal",
    title: "Tax offices exchange crypto-asset reports automatically from 2027",
    topics: const <String>["crypto", "regulation"],
    entityKinds: <EntityKind>[],
    taxYears: <int>[2026, 2027],
    grade: TaxEvidenceGrade.primary,
    verifiedOn: DateTime.utc(2026, 11, 13),
    recheckBy: DateTime.utc(2027, 4, 6),
    perimeter: KnowledgePerimeter.general,
    needsEvidence: false,
    announced: false,
    keywords: const <String>["CARF", "crypto-asset reporting framework", "OECD", "automatic exchange of information", "crypto tax reporting", "exchange account", "record keeping", "DAC8", "Kryptosteuer"],
    sources: <KnowledgeCardSource>[
      KnowledgeCardSource(
        title: "OECD, International standards on tax transparency",
        url: Uri.https("www.oecd.org", "/en/topics/international-standards-on-tax-transparency.html"),
        grade: TaxEvidenceGrade.primary,
      ),
    ],
    body: "Most large economies have adopted the OECD's Crypto-Asset Reporting\nFramework, or CARF. Approved in 2022, it makes crypto service providers\ncollect who their customers are and report their crypto transactions to a\ntax office every year, and it lets tax offices exchange those reports\nautomatically with the country where the customer lives. Around 60\njurisdictions have signed up to start exchanging in 2027, with some joining\nin 2028; the EU runs the same flow through its DAC8 rules.\n\nThe framework covers exchanges between crypto and ordinary money, between\none crypto asset and another, and transfers between service providers.\n\nWhat it means in practice: crypto activity reaches the tax office through\nthe provider's report even when nothing is filed personally, so gaps\nbetween a provider's figures and a tax return are visible on both sides.\nKeeping personal records of every trade — dates, amounts, values in local\ncurrency and fees — is the habit that keeps the numbers straight.",
  ),
  KnowledgeCard(
    id: "universal-money-emergency-fund",
    countryCode: "universal",
    title: "An emergency fund holds three to six months of essential costs",
    topics: const <String>["money", "savings"],
    entityKinds: <EntityKind>[EntityKind.individual],
    taxYears: <int>[],
    grade: TaxEvidenceGrade.primary,
    verifiedOn: DateTime.utc(2026, 11, 13),
    recheckBy: DateTime.utc(2027, 5, 31),
    perimeter: KnowledgePerimeter.general,
    needsEvidence: false,
    announced: false,
    keywords: const <String>["emergency fund", "emergency savings", "buffer", "rainy day fund", "three to six months", "instant access", "unexpected costs", "financial cushion"],
    sources: <KnowledgeCardSource>[
      KnowledgeCardSource(
        title: "MoneyHelper, Emergency savings – how much is enough?",
        url: Uri.https("www.moneyhelper.org.uk", "/en/savings/types-of-savings/emergency-savings-how-much-is-enough"),
        grade: TaxEvidenceGrade.primary,
      ),
    ],
    body: "An emergency fund is money set aside for costs that cannot be planned: a\nrepair, a broken appliance, a drop in income. MoneyHelper's rule of thumb is\nto hold three to six months of essential outgoings — rent or mortgage, food,\nheating and other bills that cannot be paused — in an account the money can\nleave quickly.\n\nThe arithmetic uses the household's own figures. Essential outgoings of\n£1,400 a month point to a target between £4,200 and £8,400. Any amount\nhelps: MoneyHelper suggests starting smaller and saving regularly, because a\nsmall fund that exists serves better than a large one that never starts.\n\nOrder matters too. MoneyHelper warns that expensive debts — credit cards,\npayday loans, mortgage arrears — usually cost more than savings earn, so\nthey are generally cleared before the fund is filled. Insurance is the\nother route to covering unexpected costs, and it can sit alongside the\nfund.",
  ),
  KnowledgeCard(
    id: "universal-money-what-aer-means",
    countryCode: "universal",
    title: "AER is the yearly savings rate with compounding included",
    topics: const <String>["money", "savings", "interest"],
    entityKinds: <EntityKind>[],
    taxYears: <int>[],
    grade: TaxEvidenceGrade.primary,
    verifiedOn: DateTime.utc(2026, 11, 13),
    recheckBy: DateTime.utc(2027, 5, 31),
    perimeter: KnowledgePerimeter.general,
    needsEvidence: false,
    announced: false,
    keywords: const <String>["AER", "annual equivalent rate", "APY", "annual percentage yield", "gross rate", "compound interest", "savings interest", "compare accounts", "Zinsertrag"],
    sources: <KnowledgeCardSource>[
      KnowledgeCardSource(
        title: "MoneyHelper, How to choose between saving and borrowing",
        url: Uri.https("www.moneyhelper.org.uk", "/en/savings/types-of-savings/how-to-choose-between-saving-and-borrowing"),
        grade: TaxEvidenceGrade.primary,
      ),
      KnowledgeCardSource(
        title: "MoneyHelper, Interest rates explained",
        url: Uri.https("www.moneyhelper.org.uk", "/en/savings/how-to-save/interest-rates-explained"),
        grade: TaxEvidenceGrade.primary,
      ),
    ],
    body: "AER — the annual equivalent rate — is what a savings balance earns over a\nfull year with compounding included, shown as a percentage. MoneyHelper\ndescribes it as the total interest received on savings in one year, and the\nfigure to read when comparing accounts, because it puts monthly and yearly\npayouts on one scale.\n\nCompounding is why two accounts with the same headline rate can pay\ndifferently. A rate paid monthly earns interest on earlier interest, so its\nAER lands above its gross rate; a rate paid once a year has an AER equal to\nthe gross rate. The US label for the same idea is APY, the annual\npercentage yield.\n\nAER says nothing about fees, access rules or how long a rate lasts, and tax\nmay still apply to the interest. MoneyHelper's interest guide shows the\narithmetic: £1,000 at 2% for one year earns £20, giving £1,020.",
  ),
];
