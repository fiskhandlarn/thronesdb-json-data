#merge data files from default English with each locale found in translations directory

fs = require 'fs'
path = require 'path'
_ = require 'lodash'

i18nDir = path.join __dirname, 'translations'
things = ['cycles', 'factions', 'packs', 'types']

stripProps = (json, props) ->
    _.map json, (item) ->
        _.pick item, props

loadThings = (root) ->
    result = {}
    for thing in things
        file = "#{thing}.json"
        filepath = path.join(root, file)
        try
            json = JSON.parse fs.readFileSync(filepath, 'UTF-8')
            result[file] = stripProps json, ["code", "name"]
    result


loadCards = (root) ->
    result = {}
    localeRoot = path.join root, 'pack'
    try
        fs.mkdirSync(localeRoot)
    files = fs.readdirSync localeRoot
    for file in files
        json = JSON.parse fs.readFileSync(path.join(localeRoot, file), 'UTF-8')
        result[file] = stripProps json, ['code','flavor','name','text','traits']
    result

things_en = loadThings __dirname
cards_en = loadCards __dirname

codes = fs.readdirSync i18nDir
for code in codes
    console.log "Updating locale '#{code}'..."
    localeRoot = path.join i18nDir, code

    l_things = loadThings localeRoot
    l_cards = loadCards localeRoot

    m_things = _.merge({}, things_en, l_things)
    m_cards = _.merge({}, cards_en, l_cards)

    for file in _.keys m_things
        target = path.join localeRoot, file
        if !_.isEqual(l_things[file], m_things[file])
            fs.writeFileSync target, JSON.stringify(m_things[file], null, 4)+"\n"
            console.log "Written #{target}"
    
    for file in _.keys m_cards
        target = path.join localeRoot, 'pack', file
        if !_.isEqual(l_cards[file], m_cards[file])
            fs.writeFileSync target, JSON.stringify(m_cards[file], null, 4)+"\n"
            console.log "Written #{target}"