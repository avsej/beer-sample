## Why This Dataset is Better?

1. It really use UTF-8
2. It uses meaningless and uniform IDs
3. All documents has type attribute
4. The bigger dataset
5. Geo attributes has names (lat, lng) instead of just two-element array

## The contents of the design document

### brewery_beers

Map

```javascript
function(doc, meta) {
  switch(doc.type) {
  case "brewery":
    emit([meta.id]);
    break;
  case "beer":
    emit([doc.brewery_id, meta.id]);
    break;
  }
}
```

### by_key_value

Map

```javascript
function (doc, meta) {
  for (var k in doc) {
    emit([k, String(doc[k])], 1);
  }
}
```

Reduce

```javascript
_count
```

### by_location

Map

```javascript
function (doc, meta) {
  if (doc.country, doc.state, doc.city) {
    emit([doc.country, doc.state, doc.city], 1);
  } else if (doc.country, doc.state) {
    emit([doc.country, doc.state], 1);
  } else if (doc.country) {
    emit([doc.country], 1);
  }
}
```

Reduce

```javascript
_count
```

### points

Spatial

```javascript
function(doc, meta) {
  if (doc.geo) {
    emit({type: "Point", coordinates: [doc.geo.lng, doc.geo.lat]}, [meta.id, doc.geo]);
  }
}
```
