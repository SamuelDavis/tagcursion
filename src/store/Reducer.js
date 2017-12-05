export default class Reducer {
    static reduce(state = [], {type, payload}) {
        return this[type] && this[type](payload, state) || state;

    }
}
