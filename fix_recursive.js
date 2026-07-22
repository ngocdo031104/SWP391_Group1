const fs = require('fs');
const path = require('path');
const iconv = require('iconv-lite');

function fixMojibake(text) {
    let newText = text;
    // Regex for strings in quotes
    const strRegex = /"([^"\\]*(?:\\.[^"\\]*)*)"/g;
    newText = newText.replace(strRegex, (match, p1) => {
        const buf = Buffer.from(p1, 'utf8');
        const decoded = iconv.decode(buf, 'win1258');
        if (decoded !== p1 && /[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i.test(decoded)) {
            return '"' + decoded + '"';
        }
        return match;
    });

    // Regex for single-line comments
    const commentRegex = /\/\/([^\n\r]*)/g;
    newText = newText.replace(commentRegex, (match, p1) => {
        const buf = Buffer.from(p1, 'utf8');
        const decoded = iconv.decode(buf, 'win1258');
        if (decoded !== p1 && /[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i.test(decoded)) {
            return '//' + decoded;
        }
        return match;
    });
    
    // Regex for multi-line comments
    const multiCommentRegex = /\/\*([\s\S]*?)\*\//g;
    newText = newText.replace(multiCommentRegex, (match, p1) => {
        const buf = Buffer.from(p1, 'utf8');
        const decoded = iconv.decode(buf, 'win1258');
        if (decoded !== p1 && /[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i.test(decoded)) {
            return '/*' + decoded + '*/';
        }
        return match;
    });

    return newText;
}

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(file));
        } else {
            if (file.endsWith('.java')) {
                results.push(file);
            }
        }
    });
    return results;
}

const files = walk('src/backend/Controller');
let changedCount = 0;

files.forEach(file => {
    const originalText = fs.readFileSync(file, 'utf8');
    const newText = fixMojibake(originalText);
    
    if (newText !== originalText) {
        fs.writeFileSync(file, newText, 'utf8');
        console.log('Fixed: ' + file);
        changedCount++;
    }
});

console.log('Total files fixed: ' + changedCount);
