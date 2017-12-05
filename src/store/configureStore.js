import {applyMiddleware, combineReducers, compose, createStore} from 'redux';
import Tags from "./Tags";

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
const reducer = combineReducers({
    [Tags.name]: Tags.reduce.bind(Tags)
});

export default function configureStore(initialState) {
    return createStore(reducer, initialState, composeEnhancers(
        applyMiddleware()
    ));
}
