    private
    def process_data(message)
      # json plugin:
      # преобразовывает строку json в ruby hash
      # и обходит полное hash дерево выдавая key, value другим плагинам
      Plugins.json(message) do |val1, key1|
        # sanitize plugin:
        # чистит value от HTML тэгов
        Plugins.sanitize(val1, key1) do |val2, key2|
          # href plugin:
          # по заданному ключу, заменяет URL-ы в value
          # на HTML якоря <a href="$url"> $url </a>
          Plugins.href_maker(val2, key2, 'text')
        end
        # на выходе из json-плагина hash преобразовывается обратно в строку
      end
    end