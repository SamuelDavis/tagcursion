import React from "react";
import {Provider} from "react-redux";
import {render} from 'react-dom';
import App from './components/App';
import configureStore from './store/configureStore';
import Tags from "./store/Tags";

const store = configureStore({
    [Tags.name]: [
        // t1
        {_id: 'Thud', children: ['Etc']},
        {_id: 'Grunt', children: ['Foo', 'Bar']},
        // t2
        {_id: 'Foo', children: ['Fiz', 'Baz']},
        {_id: 'Bar', children: ['Etc', 'Etc']},
        {_id: 'Qux', children: []},
        // t3
        {_id: 'Fiz', children: []},
        {_id: 'Baz', children: []},
        {_id: 'Etc', children: []},
    ].reduce((state, tag) => (state[tag._id] = tag) && state, {})
});

render(
    <Provider store={store}>
        <App/>
    </Provider>,
    document.getElementById('app')
);
