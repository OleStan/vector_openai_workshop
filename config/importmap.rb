# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "openai", to: "https://ga.jspm.io/npm:openai@3.2.1/dist/index.js"
pin "#lib/adapters/http.js", to: "https://ga.jspm.io/npm:axios@0.26.1/lib/adapters/xhr.js"
pin "axios", to: "https://ga.jspm.io/npm:axios@0.26.1/index.js"
pin "form-data", to: "https://ga.jspm.io/npm:form-data@4.0.0/lib/browser.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
