Solid::MethodWhitelist.allow(
  BasicObject => [:!],
  Object => [:present?, :blank?],
  Kernel => [:nil?],
  Enumerable => [:sort],
)
