# SafePay-SmartContract
Ethereum based solution for secure online shoping 🛍️🛒

[![Platform](https://img.shields.io/badge/Platform-Ethereum-brightgreen.svg)](https://en.wikipedia.org/wiki/Ethereum)
[![Platform](https://img.shields.io/badge/Compiler-^0.4.18-yellow.svg)](http://solidity.readthedocs.io/en/v0.4.18/)

## It's simple solution for secure online shopping.
If you buy something on a website, buyer/courier will get their money only after delivery your product. 
All info about order and shipment will be based on blockchain for transparency.

## STEP 1 - Company deploys smart contract
Company deploy smart contract and mark Buyers address.

## STEP 2 - Buyer sends order
Buyer sends order to smart contract, Company gets event about it: <br>
`function sendOrder(string product, uint quantity, string location) - // "Location" needs for detecting shipment price `

## STEP 3 - Company sends price/delivery date
The Company gets optimal price and date for shipment without the smart contract, and send it to Buyer: <br>
`function sendPrice(uint orderNo, uint priceForProduct, uint priceForDelivery, uint deliveryDate)`

## STEP 4 - Buyer sends money
If everything is ok, Buyer sends final price (for product + for shipment): <br>
`function sendSafePay(uint orderNo, uint phoneNumber)`

## STEP 5 - Company sends an invoice to Courier
Then Company sends Invoice to Courier, which will deliver product:  <br>
`function sendInvoice(uint orderNo, address courier)`

## STEP 6 - Courier delivers product and everyone gets own money
When Courier delivers product then he can call this function, and Company/Courier can get their money from the smart contract: <br>
`function delivery(uint invoiceNo, uint timestamp) - // "Timestamp" is a real date of delivered`

## STEP 7 - Buyer sends comment/feedback
Buyer can send comment/feedback to the company, and it will visible in blockchain for everyone: <br>
`function sendComment(uint orderNo, string comment)`
