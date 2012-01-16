Solid::MethodWhitelist.allow(
  BasicObject => [:!],
  Object => [:present?, :blank?, :nil?],
  Enumerable => [:sort],
)
