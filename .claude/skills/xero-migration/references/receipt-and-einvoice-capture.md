# Receipt, bill and e-invoice capture

Tags: **S** secondary, **I** inferred, **K** general knowledge. Invoice-content rules and e-invoicing timelines live in `double-entry-ledger/references/documents-and-invoicing.md`; this file covers capture only.

## 1. Pipeline [I]

1. **Ingest:** a per-organisation email-forward address, share sheet, file upload, and later a feed from the user's mailbox if they connect one.
2. **Detect type:**
   - PDF with embedded XML (ZUGFeRD or Factur-X, PDF/A-3) or a bare XML file (XRechnung, Peppol BIS Billing 3.0): parse the structured data and skip OCR.
   - Plain PDF or image: OCR or LLM extraction.
3. **Normalise** to a draft document: supplier, number, dates, currency, lines, tax by rate, totals.
4. **Validate:** arithmetic (sum of lines = net; tax per line; gross) and, for e-invoices, EN 16931 business rules before posting.
5. **Duplicate check:** supplier plus number plus amount plus date.
6. **Propose coding** from supplier history (account, tax code); the user confirms. Nothing posts without confirmation.
7. **Store the original** (PDF, image or XML) as an immutable artefact with SHA-256, attached to the document. Needed for retention (Germany: keep the structured XML as the original).

Extraction never overrides structured data. A regenerated PDF never replaces a stored original.

## 2. Country notes

### Germany

- Every business must be able to receive EN 16931 e-invoices since 1 January 2025 (an email inbox suffices). Issuing is mandatory from 1 January 2027 (prior-year turnover above EUR 800,000 in some sources, at least EUR 800,000 in others) and from 1 January 2028 for all. Formats: XRechnung, ZUGFeRD 2.x (from 2.0.1; MINIMUM and BASIC-WL excluded) and Factur-X, Peppol BIS Billing 3.0. XRechnung is mandatory for federal B2G. No government platform; Peppol is the common network. [S] https://www.cleartax.com/de/en/e-invoicing-germany , https://edicomgroup.com/blog/germany-b2b-electronic-invoice , https://docs.invopop.com/compliance/germany , https://peppolvalidator.com/peppol-germany
- A plain PDF is not an e-invoice. Parse and validate incoming XML; archive the XML original. See `double-entry-ledger` for the GoBD retention points. EN 16931, ZUGFeRD and XRechnung specifications were not fetched; implement against the official specs and the KoSIT validator, and capture sample files as fixtures.

### Nigeria

- Under the NRS Merchant-Buyer Solution, invoices from in-scope suppliers should carry an IRN and QR. One commercial source says an invoice without them does not support an input VAT credit (unverified). Store IRN, QR payload and any validation response with each received purchase invoice, and flag purchase invoices from in-scope suppliers that lack them. Whether a buyer can query NRS to validate an IRN was not researched. [S] https://vatit.com/e-invoicing-guide/nigeria/ , https://www.vatupdate.com/2026/02/19/briefing-document-podcast-e-invoicing-and-e-reporting-in-nigeria/
- Medium taxpayers go live 1 July 2026 and are enforced from January 2027, so many suppliers will still send non-conforming PDFs in 2026. Capture must handle both.

### United Kingdom

- No UK e-invoicing mandate was verified. E-invoices are optional, need customer agreement and carry the same information as paper; PDF is acceptable. Keep copies 6 years with authenticity and integrity guaranteed; scans may replace paper if legible. [P] https://www.gov.uk/guidance/electronic-invoicing-notice-70063 . MTD for VAT requires digital links between software. [P] https://www.gov.uk/guidance/record-keeping-for-vat-notice-70021
- Peppol or other structured inputs may arrive from larger suppliers; treat them as in Germany if present.

### United States

No federal e-invoice or invoice-content requirement was researched. Capture receipts and bills by OCR or LLM and keep the original image or PDF. IRS retention is in `double-entry-ledger/references/retention-and-edge-cases.md`.

## 3. OCR and extraction options (secondary pricing, check vendor sites)

- Azure Document Intelligence prebuilt invoice or receipt: about 10 USD per 1,000 pages.
- AWS Textract AnalyzeExpense: 0.01 USD per page.
- Google Document AI: 0.10 USD per document (up to 10 pages) in one comparison.
- Veryfi: from 0.08 per receipt and 0.16 per invoice with a 500 USD per month minimum.
- Mindee: sources conflict (0.10 per page vs subscription plans).
- LLM-based: Mistral OCR 4 to 5 USD per 1,000 pages; Reducto 10 to 40 USD per 1,000 pages.
- [S] https://invoicedataextraction.com/blog/best-invoice-extraction-api , https://www.edenai.co/post/top-10-ocr-invoice-parser-api , https://invoicedataextraction.com/blog/azure-ai-document-intelligence-invoice-extraction

Sending receipts to any of these shares the user's financial documents and their suppliers' data with a third party. Choose a provider only after the owner agrees; strip metadata; do not include the user's identity in requests; get user consent per organisation; keep a setting to disable cloud extraction. Do not use any provider whose terms allow training on submitted documents without explicit user opt-in. [I]

## 4. Receipt and bill capture into Xero today (for comparison)

Users currently get documents into Xero through bank-statement CSV with precoding, bills CSV import and the Documents inbox. Status of Xero's own inbox and Hubdoc-type tools in 2026 was not verified. [S] https://whatreceipt.com/guides/import-receipts-into-xero

Xero cannot bulk-export attachments, so documents come over separately and link by invoice number, date and contact. [S]

## 5. Gaps

- EN 16931, ZUGFeRD and XRechnung technical specifications not read.
- UK, US and Nigeria e-invoice capture requirements not researched in depth.
- Xero's email inbox and Hubdoc status in 2026 not verified.
