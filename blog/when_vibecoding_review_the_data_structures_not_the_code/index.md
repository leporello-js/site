# When vibecoding, do not review the code - review the data structures

When I read online discussions of vibecoding (now rebranded as "agentic programming"), I never see this simple principle being mentioned.

**If the data structures are sound, the code can be easily replaced. If the data structures are a tangled mess, the code will be ugly despite any effort.**

Here is a simple example. Imagine you have a web app powered by an RDBMS with a well thought out schema with good types (no integer ids for statuses deciphered in the app code) and foreign key constraints. I believe a frontier model can rebuild your server code and UI from scratch, just by looking at the database schema, with decent quality.

On the other hand, imagine you have hundreds of thousands of lines of vibeslop, split among multiple microservices that save data to a schemaless key-value storage. Even frontier models would fail to get a good understanding of the code base.

The worst crimes against the data are denormalization and non-transparent caching.

Even frontier models sometimes create denormalized data structures. Recently I was vibecoding an app that works with Excel tables. The app needed a simple format for representing an Excel table. The sane option is a 2d array, or maybe an array of objects where each object represents a single row in the sheet, keyed by a column name.

Instead, the frontier model used an insane denormalized format that separately stored a list of columns and a list of rows, with each cell value duplicated twice.

If the data structures are in-memory, the code can still be refactored. If the data structures are persistent (saved on disk), the refactoring becomes much more difficult. If the data is distributed, it becomes nearly impossible.

One of the reasons for data structure decay is that models tend to be conservative about the code base. I am currently vibecoding an app that stores data on the user's device. It is still early in development and it has no users. But the model is very cautious about not breaking the app for existing users by changing the format of persistent data. It had to be prompted to refactor aggressively.

Models are also too focused on the problem they are given at the moment. If they are not asked to review the overall design, they will never do that on their own.
