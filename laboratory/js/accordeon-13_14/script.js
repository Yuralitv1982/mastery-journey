const headers = document.querySelectorAll('.accordion-header');

headers.forEach(button => {
    button.addEventListener('click', () => {
        const currentItem = button.parentElement;
        const isActive = currentItem.classList.contains('active');

        // 1. Очистка: Закрываем все активные элементы
        document.querySelectorAll('.accordion-item').forEach(item => {
            item.classList.remove('active');
        });

        // 2. Действие: Если кликнутый не был активен — открываем его
        if (!isActive) {
            currentItem.classList.add('active');
        }
    });
});
