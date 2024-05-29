### Introduction

`Handy Assistant AI` is an LLM-powered IOS app that can be used to troubleshoot faulty household appliances through natural language. Users can talk an image of the product label of their appliance and OCR built into the app will extract all the required information to perform a lookup of the user manual from a database.

Due to using vector embeddings of text chunks and storing these in a vector database, these lookups are fast enough to provide context to the LLM before it begins to answer the user's inquiry. In this setup, we hope to avoid hallucinations that are common with most chat bots especially when the user's query is highly specific like in this application.

To handle the calling of APIs and database connections along with storing user images, we are using a separate backend written using Node.js and running on Firebase cloud functions.
