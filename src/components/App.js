import React from 'react';
import {connect} from "react-redux";
import Component from "./Component";
import {Col, Grid, Row} from 'react-bootstrap';
import Tag from './Tag';
import Tags from './../store/Tags';

class App extends Component {
    render() {
        const {tags = {}} = this.props;

        return <Grid>
            <Row>
                <Col xs={12}>
                    {Object.keys(tags).map(_id => <Tag key={_id} _id={_id}/>)}
                </Col>
            </Row>
        </Grid>;
    }
}

function mapStateToProps(state) {
    return {tags: state[Tags.name]};
}

export default connect(mapStateToProps)(App);
