date from MS 
```js
let date = new Date(epoch_timestamp_ms);
console.log(date.toString()); // Outputs a readable date and time
```
```js
// Specify your date and time
let date = new Date("2024-11-01T12:30:00Z"); // Replace with your desired date and time
let timestamp_ms = date.getTime();
console.log(timestamp_ms); // Outputs the timestamp in milliseconds
```