# Cross-border: residence, treaties, FIG, FEIE

Grades: **[P]** primary, **[S]** secondary, **[I]** computed, **[B]** background not fetched.

## What to ask first

1. Which country is the user tax resident in this year, and was that different in the previous three years?
2. Are they a US citizen or green-card holder? [B] They are taxed on worldwide income wherever they live, so a US person in the UK, Germany or Nigeria needs a US return and FEIE or foreign tax credit analysis.
3. Do they have income, accounts, property or a company in another country?
4. Did they arrive in or leave a country this year?

Any "yes" to 2 to 4, or a user who has come to the UK after ten or more years abroad, goes to a professional signpost (`product-rules.md`). The app may explain the test, never conclude residence for the user.

## UK Statutory Residence Test (SRT) [P]

Source: https://www.gov.uk/government/publications/rdr3-statutory-residence-test-srt/guidance-note-for-statutory-residence-test-srt-rdr3

- Automatic overseas tests: fewer than 16 days in the UK (resident in one of the previous 3 years); fewer than 46 days (not resident in the previous 3); fewer than 91 days with full-time overseas work (and under 31 days of more than 3 hours UK work, no significant break of 31 days or more).
- Automatic UK tests: 183 days or more; UK home test (91 consecutive days, 30 in the tax year, at least 30 days in that home, no overseas home or under 30 days there); full-time UK work over a 365-day period with over 75% of working days in the UK.
- Sufficient ties:
  - Table A (resident in one or more of the previous 3 years): 16 to 45 days needs 4 ties, 46 to 90 days 3, 91 to 120 days 2, over 120 days 1.
  - Table B (not resident in any of the previous 3 years): 46 to 90 days needs all 4, 91 to 120 days 3, over 120 days 2.
  - Ties: family, accommodation, work, 90-day, country. The country tie applies only if resident in one of the previous 3 years.
- Split-year cases 1 to 3 (leaving) and 4 to 8 (arriving).

Vectors: XB-1 (arrivers), XB-2 (leavers) in `test-vectors.md`.

## UK FIG regime from 6 April 2025 [S]

Sources: https://taxscape.deloitte.com/article/foreign-income-and-gains-(fig)-regime.aspx , https://assets.publishing.service.gov.uk/media/672105124da1c0d41942a8a8/Reforming_the_taxation_of_non-UK_individuals.pdf , https://www.taxtrends.co.uk/gb/the-uks-new-foreign-income-and-gains-fig-regime-ultimate-guide/ (HMRC manual references RFIG41000 and IHTM47020 appear in secondary summaries, unread).

- Available in the first four tax years of UK residence after at least ten consecutive years of non-UK residence; separate claims for foreign employment income, other foreign income and foreign gains; FIG can be brought to the UK without charge.
- Overseas Workday Relief over the same period; annual limit is the lower of £300,000 or 30% of qualifying employment income. Vector XB-3: qualifying income £400,000 gives the lower of £300,000 and £120,000 = £120,000.
- Temporary Repatriation Facility open 2025/26, 2026/27 and 2027/28 at 12% (2025/26 and 2026/27) rising to 15% (2027/28).
- IHT long-term residence from 10 of the previous 20 tax years. Most unused pension assets enter the UK IHT estate from 6 April 2027 (Finance Act 2026, S: Rathbones URL in `levers-uk.md`).

Always signpost. Do not model FIG savings in the app.

## US treaties and FEIE

- The IRS treaty list includes the United Kingdom and Germany with no caution label and does not list Nigeria. [P] https://www.irs.gov/businesses/international-businesses/united-states-income-tax-treaties-a-to-z
- FEIE: physical presence test of at least 330 full days in any 12 consecutive months; bona fide residence test needs an uninterrupted period including an entire tax year; Form 2555. The fetched page gave only the up-to-2023 amount ($120,000). [P, thin] https://www.irs.gov/individuals/international-taxpayers/foreign-earned-income-exclusion . The 2025 figure ($130,000) and the 2026 figure are [B]; do not hard-code.
- Not retrieved: FEIE versus foreign tax credit election rules (revocation, five-year lock-out), housing exclusion limits, FTC baskets and carryover, Form 1116.

## Not retrieved

UK-US (2001), UK-Germany (2010) and UK-Nigeria (1987) treaty text and tie-breaker and pension articles; Germany-Nigeria treaty status; Nigeria residence rules; German unbeschränkte Steuerpflicht (§1 EStG, Wohnsitz §8 AO, gewöhnlicher Aufenthalt §9 AO, 183-day presence); UK-US totalisation; the OECD model convention. All [B] and signpost-only. Concealing foreign accounts or income, and false residence claims, are on the never-suggest list.
