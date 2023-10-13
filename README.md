# zip-pascal

[![](https://img.shields.io/github/v/tag/thechampagne/zip-pascal?label=version)](https://github.com/thechampagne/zip-pascal/releases/latest) [![](https://img.shields.io/github/license/thechampagne/zip-pascal)](https://github.com/thechampagne/zip-pascal/blob/main/LICENSE)

Pascal binding for a portable, simple **zip** library.

### Example
```pas
program main;

{$linklib c}
{$linklib zip}

uses zip;

const
   content : Pchar = 'test content'; 
var
   z : ^zip_t;

begin
   z := zip_open('/tmp/pascal.zip', 6, 'w');

   zip_entry_open(z, 'test');

   zip_entry_write(z, content, strlen(content));
   zip_entry_close(z);
   zip_close(z);
end.
```

### References
 - [zip](https://github.com/kuba--/zip)

### License

This repo is released under the [MIT License](https://github.com/thechampagne/zip-pascal/blob/main/LICENSE).
