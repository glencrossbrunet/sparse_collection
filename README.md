# sparse_collection ![Build Status](https://travis-ci.org/glencrossbrunet/sparse_collection.png?branch=master)

> Sparse Collection is a tool set for dealing with time-sensitive sparse data sets. 

One of the things we do at **Glencross Brunet** is monitor energy consumers in real-time. Instead of saving information at a constant sample rate, we only save new records when the values change. This saves database space, but comes with baggage, for example traditional averages aren't applicable.

The module uses Riemann sum terminology (`left`, `middle`, `right`) to specify precedence for the sample time independent variable. Tons of examples below!

### How To Use

Include the gem in your Gemfile. Remember to use `Bundler.setup` if you're not using Rails. 

```ruby
# Gemfile

gem 'sparse_collection', github: 'glencrossbrunet/sparse_collection'
```

Extend the activerecord model(s) you'd like to have sparse capabilities. Collections will a `sparse` method. 

```ruby
class Model < ActiveRecord::Base
  extend SparseCollection
end
```

Specify which field the collection is time-sensitive for sparse methods. `:created_at` is the default:

```ruby
sparse_collection = Model.sparse

# or with preconditions and specific field

sparse_models = Model.where({ conditions: 'here' }).sparse(:updated_at)
```

With the sparse collection you can find records and do correct averages (show below).

### Finding Records

What was the value at (insert time)? If you had the following Sample records:

```ruby
{ id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
{ id: 2, value: 10.0, saved_at: <Date: 'Jan 5, 2013'> }
```

Then you could find them with:

```ruby
jan_3_2013 = Date.parse('Jan 3, 2013')
sparse_samples = Sample.sparse(:saved_at)

sparse_samples.find_left(jan_3_2013)
# => { id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }

sparse_samples.find_middle(jan_3_2013)
# => { id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }

sparse_samples.find_right(jan_3_2013)
# => { id: 2, value: 10.0, saved_at: <Date: 'Jan 5, 2013'> }
```

### Averages

What was the average value? If you had the following Sample records:

```ruby
{ id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
{ id: 2, value: 10.0, saved_at: <Date: 'Jan 5, 2013'> }
{ id: 3, value: 15.0, saved_at: <Date: 'Jan 6, 2013'> }
```

With a normal average, you would get `10.0` which clearly does not represent the time frame at all. Normally for sampled rates, you'll want `average_left`, but this is a library, so all are included. 

Then you could average them with:

```ruby
sparse_collection = Sample.sparse(:saved_at)

sparse_collection.average_left(:value)
# => 6.25    # ( (3 * 5.0) + (1 * 10.0) ) / 4

sparse_collection.average_middle(:value)
# => 8.75    # ( (1.5 * 5.0) + (1.5 * 10.0) + (0.5 * 10.0) + (0.5 * 15.0) ) / 4

sparse_collection.average_right(:value)
# => 11.25   # ( (3 * 10.0) + (1 * 15.0) ) / 4
```

Now suppose you want the average to go past the last record:

```ruby
end_date = Date.parse('Jan 7, 2013)
sparse_collection.ending(end_date).average_left(:value)
# => 8.0     # ( (3 * 5.0) + (1 * 10.0) + (1 * 15.0) ) / 5
```

Or suppose you want the average to start before the first record:

```ruby
start_date = Date.parse('Jan 1, 2013')
sparse_collection.beginning(start_date).average_right(:value)
# => 10.0   # ( (1 * 5.0) + (3 * 10.0) + (1 * 15.0) ) / 5
```

### Pruning Redundant Records

I just found out about this gem, and there's already a bunch of redundant records in the database. How can I permanently delete them? If you had the following Sample records:

```ruby
{ id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
{ id: 2, value: 5.00, saved_at: <Date: 'Jan 3, 2013'> }
{ id: 3, value: 5.02, saved_at: <Date: 'Jan 4, 2013'> }
{ id: 4, value: 5.01, saved_at: <Date: 'Jan 5, 2013'> }
```

Then you could prune them with:

```ruby
sparse_samples = Sample.sparse(:saved_at)

sparse_samples.prune_left(:value)
# => [
#   { id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
#   { id: 3, value: 5.02, saved_at: <Date: 'Jan 4, 2013'> }
#   { id: 4, value: 5.00, saved_at: <Date: 'Jan 5, 2013'> }
# ]

sparse_samples.prune_left(value: 0.5)
# => [
#   { id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
# ]

sparse_samples.prune_left(value: 0.1)
# => [
#   { id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
#   { id: 3, value: 5.02, saved_at: <Date: 'Jan 4, 2013'> }
# ]
```

The methods take the field to prune by, and an optional numeric delta to help determine if float values are redundant. Note that `prune_left` will never destroy the oldest record, `prune_middle` is the safest pruning option, and `prune_right` will never destroy the newest record. 

### Ensuring Records

I take a reading every 5 minutes. How do I make sure my sparse collection reflects the most recent sample? If you had the following sample:

```ruby
{ id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
```

When you ensure a new sample, it is only saved if it represents new information. If the sparse value has not changed, the sample is not saved. This only applies to `left` and `right` precedences. 

```ruby
sparse_samples = Sample.sparse(:saved_at)

new_sample = Sample.new(saved_at: Date.parse('Jan 3, 2013'), value: 5.00)
sparse_samples.ensure_left(new_sample, :value)
# => { id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
```

Same as with `prune` you may specify a delta when working with floating point values. 

```ruby
new_sample = Sample.new(saved_at: Date.parse('Jan 3, 2013'), value: 5.03)
sparse_samples.ensure_left(new_sample, value: 0.1)
# => { id: 1, value: 5.00, saved_at: <Date: 'Jan 2, 2013'> }
```

New records are saved and returned.

```ruby
new_sample = Sample.new(saved_at: Date.parse('Jan 3, 2013'), value: 7.30)
sparse_samples_ensure_left(new_sample, value: 0.5)
# => { id: 2, value: 7.30, saved_at: <Date: 'Jan 3, 2013'> }
```

At tip: the `ensure_left` and `ensure_right` methods return false if the record is invalid. This is helpful for using it in controller methods:

```ruby
# samples controller

def create
  sample = Sample.new(sample_params)
  if Sample.sparse(:saved_at).ensure(sample, :value)
    render status: 200, json: { data: sample.to_json }
  else
    render status: 422, json: { errors: sample.errors }
  end
end
```

The `ensure_left` and `ensure_right` methods return the sample `find_left` or `find_right` would return. This is helpful for keeping track of the last time the value was ensured.

```ruby
ensured_sample = sparse_samples.ensure_left(sample, :value)
ensured_sample.update_attribute(:last_checked_at, DateTime.now)
````

### Indexing

Sparse methods depend on ordering by your time-sensitive field. Make sure that it is indexed! You can create a migration to index it with:

```
$ rails g migration add_index_to_tablename_fieldname
```

And in the migration file:

```ruby
class AddIndexToTablenameFieldname < ActiveRecord::Migration
  def change
    add_index :tablename, :fieldname   # maybe add null: false, unique: true
  end
end
```

### License

MIT

---

AJ Ostrow, December 2013