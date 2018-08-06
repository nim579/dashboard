module.exports =
    shortenedNumber: (num)->
        if isNaN num
            return num

        newNum = num
        if num >= 1000000000
            newNum = (num / 1000000000).toFixed(1) + 'B'

        else if num >= 1000000
            newNum = (num / 1000000).toFixed(1) + 'M'

        else if num >= 1000
            newNum = (num / 1000).toFixed(1) + 'K'

        else
            newNum = num

        return newNum.toString().replace /\B(?=(\d{3})+(?!\d))/g, "&thinsp;"

    beautifyNumber: (num)->
        if isNaN num
            return num

        return num.toString().replace /\B(?=(\d{3})+(?!\d))/g, "&thinsp;"

    animateValue: (oldValue, value, renderFn)->
        if not value? or isNaN value
            return false

        timeout = 700
        delay = 20
        iterations = timeout / delay

        difference =  value - oldValue
        trendUp = oldValue < value
        step = Math.ceil difference/50

        to = setInterval ->
            oldValue += step
            if (trendUp and oldValue >= value) or (not trendUp and oldValue <= value)
                oldValue = value
                clearInterval to
                to = null

            renderFn? oldValue
        , delay
