---
openbudget_core: feat
---

# Fill tax years and indirect tax for Africa, the Middle East and Central Asia

The 98 servable countries of Africa (including the Indian Ocean and Atlantic territories), the Middle East and Gulf, Central Asia, the Caucasus and the European countries outside the EU/EEA/OECD now carry their individual tax year, default company year end, VAT/GST/sales-tax rates (effective-dated), tax authority, graded sources, `verifiedOn`, `recheckBy` and caveats — task U5 of the tax jurisdictions plan, completing the U3/U4/U5 research pass: every servable ISO 3166-1 country now has research data. Non-Gregorian tax years are modelled with a `calendar` field and caveats: Ethiopia (1 Hamle–30 Sene, 8 July–7 July), Afghanistan (solar year, 21 March–20 March) and Saudi Arabia's Hijri zakat year. Rate changes since 2022 are effective-dated rows, never overwritten: Bahrain 5%→10%, Saudi 5%→15%, Botswana's temporary 12% cut, Kazakhstan 12%→16%, Uzbekistan 15%→12%, Tajikistan 15%→14% (→13% pre-recorded for 2027), Chad 18%→17.5%, Zimbabwe 15%→15.5%, Malawi 16.5%→17.5%, Liberia 10%→12%→13%, Ghana's levy restructuring and Montenegro's 2025 band. Countries with no VAT/GST (the Gulf non-adopters, Iraq, Syria, Libya, Afghanistan, Guernsey, Gibraltar, Greenland, Mayotte, St Helena, Eritrea, the Vatican and the uninhabited territories) use the schema's `none` kind with a source.
