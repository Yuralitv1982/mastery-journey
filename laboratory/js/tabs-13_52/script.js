console.log('Project tabs-13_52 initialized');

const tabs = document.querySelectorAll('.tab-btn');
const panes = document.querySelectorAll('.tab-pane');

tabs.forEach(tab => {
    tab.addEventListener('click', () => {
        // 1. СБРОС (Cleanup)
        // Проходим по всем кнопкам и убираем у них active
        tabs.forEach(t => t.classList.remove('active'));
        // Проходим по всем блокам контента и убираем у них active
        panes.forEach(p => p.classList.remove('active'));

        // 2. ДЕЙСТВИЕ (Action)
        // Добавляем класс active той кнопке, на которую кликнули
        tab.classList.add('active');

        // Получаем ID блока из data-target кнопки
        const targetId = tab.dataset.target; // например, "tab-2"

        // Находим нужный блок по ID и зажигаем его
        const targetPane = document.getElementById(targetId);
        if (targetPane) {
            targetPane.classList.add('active');
        }
    });
});