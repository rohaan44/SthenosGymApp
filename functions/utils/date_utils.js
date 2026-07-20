function parseDate(dateString) {
    const [year, month, day] = dateString
        .split("-")
        .map(Number);

    return new Date(year, month - 1, day);
}

function addDays(date, days) {
    const d = new Date(date);

    d.setDate(d.getDate() + days);

    return d;
}

function addMonths(date, months) {
    const d = new Date(date);

    d.setMonth(d.getMonth() + months);

    return d;
}

function isSameDate(date1, date2) {
    return (
        date1.getFullYear() === date2.getFullYear() &&
        date1.getMonth() === date2.getMonth() &&
        date1.getDate() === date2.getDate()
    );
}

module.exports = {
    parseDate,
    addDays,
    addMonths,
    isSameDate,
};