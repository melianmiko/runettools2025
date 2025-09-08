// ==UserScript==
// @name         YandexTranslateAsAnProxy
// @namespace    http://tampermonkey.net/
// @version      2025-09-08
// @description  Fuck off
// @author       MelianMiko
// @match        https://translated.turbopages.org/*
// @match        https://ya.ru/search*
// ==/UserScript==

(function() {
    'use strict';

    const asleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay));

    const retry = async (factory) => {
        let hop = 0;

        while(true) {
            const el = await factory(hop);
            if(el) return el;

            await asleep(250);
        }
    };

    const processTranslatePage = async () => {
        // Отключаем перевод
        await retry(async () => {
            let btn = document.getElementById("tr-stripe__button_src");
            if(!btn) return false;
            btn.click();
            await asleep(50);

            btn = document.getElementById("tr-stripe__button_src");
            if(!btn) return false;
            return btn.classList.contains("tr-stripe__button_active");
        });

        // Закрываем тулбар
        await retry(async () => {
            let btn = document.getElementById("closeHeader");
            if(!btn) return false;
            btn.click();
            await asleep(50);
        });
    };

    const processSearch = async () => {
        const root = document.getElementById("search-result");

        for(const item of [...root.getElementsByClassName("Organic")]) {
            const itemTitleLink = item.getElementsByClassName("OrganicTitle-Link")[0];
            if(!itemTitleLink) continue;

            const itemUrl = itemTitleLink.href;

            const translateLink = document.createElement("a");
            translateLink.innerText = "Чебурнет-mode";
            translateLink.className = "Link Link_theme_normal FuturisSource FuturisSource_compact";
            translateLink.style.marginTop = "16px";
            translateLink.target = "_blank";
            translateLink.href = `https://translate.yandex.ru/translate?view=compact&url=${encodeURIComponent(itemUrl)}&lang=en-ru`;

            item.appendChild(translateLink);
        }

        console.log(1111);
    };

    window.addEventListener("load", async () => {
        switch(location.host) {
            case "translated.turbopages.org":
                return processTranslatePage();
            case "ya.ru":
                if(location.pathname.startsWith("/search/touch")) {
                    return processSearch();
                }
                break;
        }
    })
})();
