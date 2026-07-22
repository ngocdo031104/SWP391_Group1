const fs = require('fs');
const path = require('path');

const replacements = {
    "Ä Æ°á» ng": "Đường",
    "Ä Ă£": "Đã",
    "quyá» n": "quyền",
    "Há» ": "Họ",
    "Ä á»‹nh": "Định",
    "chá» n": "chọn",
    "Ä Ă¡nh": "Đánh",
    "Ä‘á» c": "đọc",
    "lá» i má» i": "lời mời",
    "bây giá» ": "bây giờ",
    "giá» ": "giờ"
};

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
    let newText = originalText;
    
    for (const [bad, good] of Object.entries(replacements)) {
        newText = newText.split(bad).join(good);
    }
    
    if (newText !== originalText) {
        fs.writeFileSync(file, newText, 'utf8');
        console.log('Fixed literally: ' + file);
        changedCount++;
    }
});

console.log('Total files fixed literally: ' + changedCount);
