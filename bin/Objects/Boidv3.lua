--common functions among screen objects
local Boid = Object:extend()



function Boid:new(orderedUpdate,x,y,opts)
  self.x =x
  self.y = y
  self.w = 5
  
  
  
  self.collider = orderedUpdate.physicsWorld:newCircleCollider(self.x,self.y,self.w)
  self.collider:setObject(self)
  self.collider:setCollisionClass("Boid")    


  self.rotation = opts.rotation
	self.rotationVelocity = 1.77*math.pi
	self.speed = opts.velocity
	self.maxSpeed = 50
	self.acceleration = 20
  
  self.velocity = Vector.new(self.speed*math.cos(self.rotation),self.speed*math.sin(self.rotation))
  self.canObserve = true 
  
  
  input:bind("mouse1","spawnBoid")
  
end

function Boid:update(dt)
  clamp(0,self.speed, self.maxSpeed)
  if self.canObserve then
    self:observe(dt)
  end
  --sync collider and drawable
  if self.collider then 
    if self.x < -self.w then 
      self.collider:setPosition(SCREEN_WIDTH + self.w, self.y) 
      self.x,self.y = self.collider:getPosition() 
      end
    if self.y < -self.w then 
      self.collider:setPosition(self.x,SCREEN_HEIGHT+self.w) 
      self.x,self.y = self.collider:getPosition() 
      end
    if self.x > self.w + SCREEN_WIDTH then 
      self.collider:setPosition(-self.w, self.y) 
      self.x,self.y = self.collider:getPosition() 
      end
    if self.y > self.w + SCREEN_HEIGHT then
      self.collider:setPosition(self.x, -self.w) 
      self.x,self.y = self.collider:getPosition() 
      end
    self.x,self.y = self.collider:getPosition() 
    self.collider:setLinearVelocity(self.velocity:getX(),self.velocity:getY())
	end
end

function Boid:draw()
 love.graphics.line(self.x+1*self.w*math.cos(self.rotation),
							self.y+1*self.w*math.sin(self.rotation),
							self.x+1.3*self.w*math.cos(self.rotation),
							self.y+1.3*self.w*math.sin(self.rotation))
  
end



function Boid:observe(dt)
  --self.canObserve = false
  --get all the coliders close to this one  and get the object they belong to
  local colliders = orderedUpdate.physicsWorld:queryCircleArea(self.x,self.y,observeRange)
  local nearbyBoids = {}
  --if there are other colliders around
  if #colliders>1 then
    for i,collider in ipairs(colliders) do
        if collider.collision_class == "Boid" then
          table.insert(nearbyBoids,collider:getObject())
        end
    end
  end
  self:aligment(nearbyBoids)
  
end




function Boid:aligment(nearbyBoids)
  local sum = Vector.new(0,0)
  for i,boid in ipairs(nearbyBoids) do
    Vector.__add(boid.velocity,sum)
  end
  sum:normalize();
  Vector.__mul(sum)
  
end




function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end



return Boid