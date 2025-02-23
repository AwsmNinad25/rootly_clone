// app/assets/javascripts/modal.js

function openModal(id) {
    document.getElementById("incident-modal-" + id).style.display = "block";
  }
  
  function closeModal(id) {
    document.getElementById("incident-modal-" + id).style.display = "none";
  }
  
  // Close modal if clicking outside of the modal
  window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(function(modal) {
      if (event.target == modal) {
        modal.style.display = "none";
      }
    });
  };
  