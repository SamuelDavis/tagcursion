import React from 'react';
import {connect} from "react-redux";
import Component from "./Component";
import {ListGroup, ListGroupItem} from 'react-bootstrap';
import Tags from './../store/Tags';

class Tag extends Component {
    render() {
        const {_id = '???', children = []} = this.props.model || {};
        const childrenAggregate = Object.values(children.reduce((aggregate, _id) => {
            aggregate[_id] = aggregate[_id] || {_id, count: 0};
            aggregate[_id].count++;
            return aggregate;
        }, {}));

        return <ListGroup>
            <ListGroupItem>{_id}</ListGroupItem>
            {childrenAggregate.map(props => <Tag key={props._id} {...props}/>)}
        </ListGroup>;
    }
}

function mapStateToProps(state, {_id}) {
    const model = state[Tags.name][_id];
    return {model};
}

export default connect(mapStateToProps)(Tag);
