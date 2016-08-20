import 'bootstrap/dist/css/bootstrap.css'
import './assets/css/styles.css'


console.log('hello!');
fetch('http://localhost:5000/api/hello', {origin: "Access-Control-Allow-Origin"})
    .then( (response) => {
        console.log(response);
    });
