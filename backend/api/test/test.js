// const data = {
//     email_id: "yavsvaibhav@gmail.com",
//     password: "Hello world",
// };

// fetch("http://127.0.0.1:8000/auth/signin/", {
//     method: "POST",
//     mode: "no-cors",
//     headers: {
//         Accept: "application/json",
//         "Content-Type": "application/json",
//     },

//     body: JSON.stringify(data),
// }).then((value) => {
//     console.log(value);
// });

const xhr = new XMLHttpRequest();
xhr.open("POST", "http://127.0.0.1:8000/event/fetch_qr");
xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8");
const body = JSON.stringify({
    access_token:
        "eyJhbGciOiJIUzI1NiIsImtpZCI6IjNXb01Ub1YrZ3IraW1aRlEiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjkzODI0OTU4LCJpYXQiOjE2OTM4MjEzNTgsImlzcyI6Imh0dHBzOi8vamNuc2pxcWxnem5saHBlanN3bG0uc3VwYWJhc2UuY28vYXV0aC92MSIsInN1YiI6IjcyYWI0NDAzLWRjNDQtNGNjYS1iNjM2LWFkYjFmOGQ0MGM2MCIsImVtYWlsIjoiaGVsbG90aGVyZUBnbWFpbC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7fSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJwYXNzd29yZCIsInRpbWVzdGFtcCI6MTY5MzgyMTM1OH1dLCJzZXNzaW9uX2lkIjoiZmFkZTA0OTItZTMwYi00NzZiLTkyNzUtZjRkNGFiMDhhM2QzIn0.pEsP5tKWo8_3dMW3p5m7PEP1XfhZheDv2VFvDJ-nmEE",
    refresh_token: "FrignqcxyHYHo1gHftu8KQ",
    supabase_id: "72ab4403-dc44-4cca-b636-adb1f8d40c60",
    // email_id: "hellothere@gmail.com",
    // password: "hello world",
});
xhr.onload = () => {
    if (xhr.readyState == 4 && xhr.status == 201) {
        console.log(JSON.parse(xhr.responseText));
    } else {
        console.log(JSON.parse(xhr.responseText));
    }
};
xhr.send(body);
