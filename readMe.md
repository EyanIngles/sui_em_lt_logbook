# Concept 
in australia, we have a lot of shonky sites that are dealing with electrical certs, lighting logs and they are just written, no proof someone has signed them....

lets fix that with blockchain, store data with someone signing a bundle or one item.

**we will give them a struct of such**
```js
 public struct Light_item has store, copy { // not UID because it is going to be copied to a data base styled server?
 signer: address, // the person who has signed to prove it was them who checked it.
 school: String, // the name of the school.
 em_id: String, // perhaps should have an id number such as EM01, EM02 and use a map to see where they should be situated.
 location: String, // the location of where the EM is located.
 test_time_in_minutes: u64, // the time tested 90mins is regs
 test_pass: bool, // did the test pass or fail.
 date_and_time: u64, // use epoch values and convert them, this will be stamped on once the item has been created.
 }
```

we push the pass ones into a checker to ensure if they used 90 minutes to test or not.

for quick ptb calling when creating a new em list
```bash
\"school\" \"location\" \"em_ID_1\" 90 true
```