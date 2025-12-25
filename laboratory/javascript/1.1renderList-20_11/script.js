console.log('Project 1.1renderList-20_11 initialized');

const listArray = ['task_1', 'task_2', 'task_3', 'task_4']
const wrapper = document.querySelector('.wrapper');

const ul = document.createElement('ul')

function render(list) {
    console.log(list)
    list.forEach(element => {
        const li = document.createElement('li');
        li.textContent = element;
        ul.append(li);
    })

    wrapper.append(ul);
}

render(listArray)
