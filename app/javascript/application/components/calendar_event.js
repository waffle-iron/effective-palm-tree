import React from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'
import { Link } from 'react-router'
import moment from 'moment-timezone'
import Event from '../models/event'

class CalendarEvent extends React.Component {
  constructor(props) {
    super(props)
    const { event, member } = props
    this.state = { availability: event.availabilityFor(member) }
  }

  render() {
    const { event, member } = this.props
    const { availability } = this.state
    const classes = {
      available: availability == Event.AVAILABLE,
      unavailable: availability == Event.UNAVAILABLE,
      unknown: availability == Event.UNKNOWN
    }
    return (
      <li className={classNames(classes)}>
        <button onClick={this.cycle.bind(this)}>
          <svg width="39" height="39" viewBox="0 0 39 39">
            <circle cx="19.5" cy="19.5" r="11"/>
            <g className="check"><path d="M13.5 19.5l4 4 8-8"/></g>
            <g className="cross"><path d="M15.5 15.5l8 8"/><path d="M23.5 15.5l-8 8"/></g>
            <g className="question"><path d="M19.5 21.5v-1c1.6 0 3-1.4 3-3s-1.4-3-3-3c-1.2 0-2.3.9-2.8 1.9"/><path d="M19.5 24.5v1"/></g>
          </svg>
        </button>
        <Link to={event.url}>
          <b>{event.name}</b>
          <small>{event.startsAt.format('h:mmA')}</small>
        </Link>
      </li>
    )
  }

  cycle() {
    const { event, member, onChange } = this.props
    if (moment().isBefore(event.startsAt)) {
      let { availability } = this.state
      availability = Event.cycleAvailability(availability)
      onChange(event, member, availability)
      this.setState({ availability })
    }
  }
}

const mapStateToProps = ({ user, groups }, { event }) => ({
  member: groups[event.groupId].currentMember
})

export default connect(mapStateToProps)(CalendarEvent)
