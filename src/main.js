import App from './components/App';
import AsyncComputed from 'vue-async-computed';
import Vue from 'vue';

import 'bootstrap/dist/css/bootstrap.css';

Vue.use(AsyncComputed);

new Vue({
    el: '#app',
    template: '<App/>',
    components: {App}
});
