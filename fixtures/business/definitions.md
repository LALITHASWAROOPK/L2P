# Northstar Supply: synthetic sales definitions

All data and report metadata are fictional. No real customer data is included.
The platform metadata is normalized fixture content, not native validated app exports.

- Ordered value: order-line quantity multiplied by unit price; order-date basis.
  Includes orders without invoices. This is a bookings measure, not recognized revenue.
- Invoiced sales: invoice-line ExtendedPrice minus TaxAmount; invoice-date basis.
  This simplified demo calls that revenue, without claiming accounting revenue recognition.
- ExtendedPrice includes tax in the synthetic invoice dataset.
- No currencies, discounts, returns or cancellations are modeled.
- Customers and products are shared between the two reporting paths.
- A product may belong to multiple stock groups. There is no designated primary group
  or approved allocation weighting. Group totals are therefore not necessarily additive.
- A proposed daily customer/product product must specify its date basis, tax treatment
  and grain. Do not silently substitute orders for invoices or invent missing dates.
- Qlik Sales Performance uses orders. Spotfire Customer Sales uses invoices.
  Both use all loaded dates and amounts excluding tax; differing tax treatment is not
  an explanation for a difference between these particular two synthetic reports.
