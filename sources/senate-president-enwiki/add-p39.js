module.exports = (id, startdate, enddate) => {
  qualifier = { }
  if(startdate) qualifier['P580'] = startdate
  if(enddate)   qualifier['P582'] = enddate

  return {
    id,
    claims: {
      P39: {
        value: 'Q60824201',
        qualifiers: qualifier,
        references: { P4656: 'https://en.wikipedia.org/wiki/President_of_the_Senate_(Mexico)' }
      }
    }
  }
}
