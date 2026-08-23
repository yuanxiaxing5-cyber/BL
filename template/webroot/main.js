const pages = document.querySelectorAll('.page');
const navBtns = document.querySelectorAll('.nav-btn');
const logDiv = document.getElementById('log');

navBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        navBtns.forEach(b => b.classList.remove('active'));
        pages.forEach(p => p.classList.remove('active'));
        btn.classList.add('active');
        const targetPage = document.getElementById(btn.dataset.page);
        if (targetPage) targetPage.classList.add('active');
    });
});

async function runScript(scriptName, successText) {
    if (!logDiv) return;
    logDiv.innerText = "⏳ 正在执行...";
    try {
        if (typeof ksu !== 'undefined' && ksu.exec) {
            await ksu.exec(`sh /data/adb/modules/oh_my_keymint/webroot/${scriptName}`);
            logDiv.innerText = `✅ ${successText}`;
            setTimeout(() => {
                logDiv.innerText = "等待执行...";
            }, 3000);
        } else {
            logDiv.innerText = "❌ 未检测到 KernelSU / APatch 环境";
            setTimeout(() => {
                logDiv.innerText = "等待执行...";
            }, 2500);
        }
    } catch (e) {
        logDiv.innerText = "❌ 执行失败";
        setTimeout(() => {
            logDiv.innerText = "等待执行...";
        }, 2500);
    }
}

const execBtn = document.getElementById('execBtn');
if (execBtn) {
    execBtn.addEventListener('click', () => runScript('script3.sh', 'ts密钥远程更新成功等待下载替换'));
}

const execBtnAll = document.getElementById('execBtnAll');
if (execBtnAll) {
    execBtnAll.addEventListener('click', () => runScript('script.sh', '一键配置执行成功'));
}

const execBtnAll2 = document.getElementById('execBtnAll2');
if (execBtnAll2) {
    execBtnAll2.addEventListener('click', () => runScript('script2.sh', '一键配置(scene版)执行成功'));
}
