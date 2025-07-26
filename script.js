document.addEventListener('DOMContentLoaded', () => {
    // --- IMPORTANT: REPLACE THIS WITH YOUR N8N URL ---
    const N8N_BASE_URL = 'https://groviaindia.app.n8n.cloud/webhook/';
    // --------------------------------------------------

    const loadingState = document.getElementById('loading-state');
    const slotsContainer = document.getElementById('slots-container');
    const confirmationMessage = document.getElementById('confirmation-message');

    // Get the confirmation_id from the page URL
    const params = new URLSearchParams(window.location.search);
    const confirmationId = params.get('confirmation_id');

    if (!confirmationId) {
        loadingState.innerHTML = '<p>Error: Confirmation ID is missing.</p>';
        return;
    }

    // Function to fetch available slots from your n8n API
    async function fetchAvailability() {
        try {
            const response = await fetch(`${N8N_BASE_URL}get-availability?confirmation_id=${confirmationId}`);
            if (!response.ok) throw new Error('Network response was not ok.');
            
            const busySlots = await response.json();
            renderSlots(busySlots);

        } catch (error) {
            loadingState.innerHTML = '<p>Sorry, there was an error fetching available times. Please try again later.</p>';
            console.error('Fetch error:', error);
        }
    }

    // Function to display the time slots on the page
    function renderSlots(busySlots) {
        const now = new Date();
        let slotsHtml = '';

        // Generate slots for the next 3 business days
        for (let i = 0; i < 3; i++) {
            let day = new Date(now);
            day.setDate(now.getDate() + i);

            // Skip weekends
            if (day.getDay() === 0 || day.getDay() === 6) continue;

            slotsHtml += `<h3>${day.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</h3>`;

            // Generate hourly slots from 9 AM to 5 PM
            for (let hour = 9; hour < 18; hour++) {
                const slotTime = new Date(day);
                slotTime.setHours(hour, 0, 0, 0);

                const isSlotBusy = busySlots.some(busy => {
                    const busyStart = new Date(busy.start);
                    const busyEnd = new Date(busy.end);
                    return slotTime >= busyStart && slotTime < busyEnd;
                });
                
                const isPast = slotTime < new Date();

                const button = document.createElement('button');
                button.classList.add('slot');
                button.innerText = slotTime.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
                
                if (isSlotBusy || isPast) {
                    button.classList.add('busy');
                    button.disabled = true;
                } else {
                    button.onclick = () => confirmSlot(slotTime);
                }
                slotsHtml += button.outerHTML;
            }
        }

        slotsContainer.innerHTML = slotsHtml;
        loadingState.classList.add('hidden');
        slotsContainer.classList.remove('hidden');
    }
    
    // Function to confirm the selected slot by calling your n8n API
    async function confirmSlot(selectedTime) {
        slotsContainer.classList.add('hidden');
        loadingState.classList.remove('hidden');

        try {
            const isoTime = selectedTime.toISOString();
            const response = await fetch(`${N8N_BASE_URL}confirm-reschedule?confirmation_id=${confirmationId}&new_datetime=${isoTime}`);
            if (!response.ok) throw new Error('Confirmation failed.');

            loadingState.classList.add('hidden');
            confirmationMessage.classList.remove('hidden');

        } catch (error) {
             slotsContainer.innerHTML = '<p>Sorry, there was an error confirming the time. Please try again.</p>';
             console.error('Confirmation error:', error);
        }
    }

    // Start the process
    fetchAvailability();
});