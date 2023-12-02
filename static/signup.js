$(document).ready(function() {
    $('#signupButton').on('click', function() {
      var formData = $('#signupForm').serialize(); // Serialize form data
      
      $.ajax({
        type: 'POST',
        url: '/submit_form',
        data: formData,
        success: function(response) {
          // Handle the JSON response from Flask
          if (response.status === 'error') {
            // Display an alert for error message
            alert(response.message);
          } else {
            // Show success message or perform other actions if needed
            alert('Form submitted successfully');
            // Optionally, you can redirect the user or perform other actions on success
          }
        },
        error: function(err) {
          // Handle any errors that occur during the request
          console.error('Error:', err);
        }
      });
    });
  });