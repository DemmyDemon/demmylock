--[[
    This is where I place the default codes during development.
    The idea is that the server I cooperate with in the development of demmylock
    will override these codes in their codes/ directory, so their codes remain
    a secret. I don't think they'd want their codes openly displayed on GitHub!
--]]

AddCodes('Bennys', {_default = '1270'})
AddCodes('Bolingbroke', {_default = '4680'})
AddCodes('Gentlemen', {
    _default = '1337',
    ['Isboxen'] = '*44#',
    ['Kontoret'] = '1881',
})
AddCodes('Lost MC',{
    _default = '1212',
    ['Grinden'] = '1234',
    ['Till verkstaden'] = {'1212'},
    ['Till klubben'] = {'1212'},
})
AddCodes('Mekonomen', {_default = '1993'})
AddCodes('Mission Row', {
    _default = '#911',
    ['Polischefen'] = '8019',
    ['Cell 1'] = '*010',
    ['Cell 2'] = '*020',
    ['Cell 3'] = '*030',
    ['Vapenlager'] = '#99#',
    ['Bevisförvar'] = '1243',
})
AddCodes('Playboy Mansion', {
    _default='9181',
    ['Stuvad kanin'] = '2619',
    ['Kontoret'] = '7331',
})
AddCodes('Playboy Perimeter', {_default = '#999'})
AddCodes('Sheriff Paleto', {_default='1191'})
AddCodes('Sheriff Sandy', {_default='1911'})
AddCodes('Sjukhuset', {_default = '112#'})
AddCodes('Tvättaren', {
    ['Ingång'] = {'*69*'},
})

-- Adding *new* codes below here, just to be nice to Mike. HI MIKE!
-- I'll put dates on it so it's easy to see what was added when.

-- 2020-02-20
AddCodes('Madrazo Ranch', {
    _default='1236',
    ['Källaren'] = '1247',
    ['Lagret'] = '1427',
})

-- 2020-02-21
AddCodes('Bilcenter', {
    _default = '1277',
    ['Chefskontoret'] = '1377',
})