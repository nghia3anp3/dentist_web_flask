document.getElementById('signupButton').addEventListener('click', function(event) {
    event.preventDefault(); // Prevent the default form submission behavior

    var formData = new FormData(document.getElementById('signupForm'));

    fetch('/submit_form', {
      method: 'POST',
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'error') {
        alert(data.message);
      } else if (data.status === 'success') {
        alert(data.message);
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
  });