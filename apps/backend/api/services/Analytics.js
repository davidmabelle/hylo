const sails = require('sails')
import { v4 as uuidv4 } from 'uuid'
var instance

const noopInstance = {
  track: function (opts) { sails.log.verbose('Analytics.track (disabled): ' + JSON.stringify(opts)) },
  identify: function () {},
  page: function () {},
  flush: function (cb) { if (cb) cb() }
}

if (process.env.NODE_ENV === 'test' || !process.env.SEGMENT_KEY) {
  instance = noopInstance
} else {
  try {
    instance = require('analytics-node')(process.env.SEGMENT_KEY)
  } catch (e) {
    sails.log.warn('Analytics: Segment init failed, using noop:', e.message)
    instance = noopInstance
  }
}

instance.pixelUrl = function (emailName, props) {
  var prefix = 'https://api.segment.io/v1/pixel/track?data='

  var data = {
    writeKey: process.env.SEGMENT_KEY,
    event: 'Viewed Email: ' + emailName,
    properties: props
  }

  if (props.userId) {
    data.userId = props.userId
  } else {
    data.anonymousId = uuidv4()
  }

  var encodedData = Buffer.from(JSON.stringify(data), 'utf8').toString('base64')
  return prefix + encodedData
}

instance.trackSignup = function (userId, req) {
  let properties = {platform: 'Web'}
  if (req.headers['ios-version']) {
    properties.platform = 'ios'
  } else if (req.headers['android-version']) {
    properties.platform = 'android'
  }
  this.track({
    userId,
    event: 'Signup success',
    properties})
}

module.exports = instance
